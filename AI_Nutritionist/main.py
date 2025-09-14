import logging
from fastapi import FastAPI,HTTPException
from fastapi.middleware.cors import CORSMiddleware
import pandas as pd
import joblib
import numpy as np
from sentence_transformers import SentenceTransformer
from sklearn.metrics.pairwise import cosine_similarity
import pyrebase
from typing import List, Dict, Optional
from pydantic import BaseModel
from requests.exceptions import HTTPError
import os, json, time, re
from dotenv import load_dotenv
load_dotenv()
from openai import OpenAI
import datetime as _dt
# -----------------------------------

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -------------------- Models & Data --------------------
model = joblib.load("calorie_prediction_model.pkl")
meal_embeddings = np.load("meal_embeddings.npy")
df = pd.read_csv("meal_suggestion_meal_plans_2_clean_replaced.csv")
meal_suggestion_model = SentenceTransformer("meal_suggestion_sentence_model")

# Ingredient mapping from CSV

INGREDIENTS_CSV_PATH = "all_recipe_ingredients.csv"  # reuse your existing constant if you have it

_EXPECTED_COLS = ["Recipe", "Ingredient", "Alternative_1", "Alternative_2", "Alternative_3"]

def _load_ingredient_df(path: str) -> pd.DataFrame:
    """
    Robustly read the ingredients CSV:
    - Try strict read (fast).
    - If it fails, fall back to python engine + skip bad lines.
    - Ensure required columns exist, fill missing with "".
    - Trim whitespace and fillna.
    """
    try:
        df = pd.read_csv(path, usecols=_EXPECTED_COLS, dtype=str)
    except Exception as e:
        logging.warning("Strict CSV read failed: %s. Trying tolerant mode...", e)
        try:
            df = pd.read_csv(
                path,
                engine="python",
                sep=",",
                quotechar='"',
                on_bad_lines="skip",  # pandas >= 1.3
                dtype=str,
            )
        except Exception as e2:
            logging.error("Tolerant CSV read also failed: %s", e2)
            # Final fallback: empty DF with expected columns
            df = pd.DataFrame(columns=_EXPECTED_COLS, dtype=str)

        # make sure we have all required columns
        for col in _EXPECTED_COLS:
            if col not in df.columns:
                df[col] = ""
        df = df[_EXPECTED_COLS]

    # normalize values
    df = df.applymap(lambda x: x.strip() if isinstance(x, str) else x).fillna("")
    return df

ingredient_df = _load_ingredient_df(INGREDIENTS_CSV_PATH)


# --- Optional fallback map ---
RECIPE_FALLBACK_MAP = {
    "Upma with vegetables": ["semolina", "carrots", "peas", "onion", "mustard seeds", "green chili"],
    "Oats with banana and nuts": ["oats", "banana", "almonds", "milk", "honey"],
    "Protein shake with banana": ["protein powder", "banana", "milk", "peanut butter"],
    "Paneer wrap with veggies": ["paneer", "whole wheat wrap", "capsicum", "onion", "yogurt sauce"],
    "Chicken salad with whole grain bread": ["chicken breast", "lettuce", "tomato", "whole grain bread", "olive oil"],
    "Chicken curry with brown rice": ["chicken", "onion", "tomato", "spices", "brown rice"],
    "Vegetable biryani": ["basmati rice", "carrot", "peas", "beans", "biryani masala", "onion"],
    "Chapati with dal and mixed vegetables": ["whole wheat flour", "lentils", "carrots", "beans", "spices"],
    "Turkey chili": ["turkey", "kidney beans", "onion", "tomato", "chili powder"],
    "Fruit smoothie": ["banana", "berries", "milk", "honey"],
    "Boiled eggs": ["eggs", "salt"],
    "Banana and peanut butter": ["banana", "peanut butter"],
    "Nuts and dry fruits": ["almonds", "cashews", "raisins", "dates"],
    "Baked fish with quinoa": ["fish fillet", "quinoa", "lemon", "garlic", "olive oil"],
    "Brown rice with spinach curry": ["brown rice", "spinach", "onion", "tomato", "spices"],
    "Egg sandwich with veggies": ["eggs", "bread", "lettuce", "tomato", "cucumber", "mayonnaise"],
    "Grilled chicken with vegetables": ["chicken breast", "zucchini", "bell pepper", "olive oil", "spices"],
    "Hummus with carrot sticks": ["chickpeas", "tahini", "garlic", "olive oil", "lemon", "carrots"],
    "Lentil soup with whole grain bread": ["lentils", "onion", "carrot", "celery", "spices", "whole grain bread"],
    "Mixed nuts and seeds": ["almonds", "cashews", "pumpkin seeds", "sunflower seeds"],
    "Muesli with fruits": ["rolled oats", "banana", "apple", "milk", "yogurt", "raisins"],
    "Omelette with whole grain toast": ["eggs", "onion", "tomato", "spinach", "whole grain bread"],
    "Peanut butter toast with fruits": ["bread", "peanut butter", "banana", "apple"],
    "Quinoa salad with chickpeas": ["quinoa", "chickpeas", "cucumber", "tomato", "lemon", "olive oil"],
    "Rajma with brown rice": ["kidney beans", "onion", "tomato", "garlic", "spices", "brown rice"],
    "Roti with tofu and vegetables": ["whole wheat flour", "tofu", "capsicum", "onion", "spices"],
    "Smoothie with spinach and banana": ["banana", "spinach", "milk", "honey"],
    "Steamed broccoli and almonds": ["broccoli", "almonds", "olive oil", "garlic"],
    "Stir-fried tofu with vegetables": ["tofu", "capsicum", "carrots", "soy sauce", "garlic"],
    "Sweet potato and black bean salad": ["sweet potato", "black beans", "onion", "lime", "coriander"],
    "Vegetable and bean soup": ["mixed vegetables", "kidney beans", "onion", "garlic", "spices"],
    "Vegetable poha": ["flattened rice", "onion", "potato", "peas", "mustard seeds"],
    "Vegetable stir fry with tofu": ["tofu", "broccoli", "carrot", "bell pepper", "soy sauce"],
    "Whole grain cereal with milk": ["whole grain cereal", "milk"],
    "Yogurt with granola and fruits": ["yogurt", "granola", "banana", "berries", "honey"],
    "Zucchini noodles with marinara sauce": ["zucchini", "tomato", "garlic", "olive oil", "basil"],
    "Apple slices with peanut butter": ["apple", "peanut butter"]
}



# -------------------- Firebase Setup --------------------
# Fill these from Firebase console (Project Settings → General & RTDB URL)
firebase_config = {
    "apiKey":           "AIzaSyCwN-kude9aGOxi89OEHKMcdlS-P0JMWfQ",
    "authDomain":       "ainutritionist-ca72f.firebaseapp.com",
    "databaseURL":      "https://ainutritionist-ca72f-default-rtdb.asia-southeast1.firebasedatabase.app",
    "projectId":        "ainutritionist-ca72f",
    "storageBucket":    "ainutritionist-ca72f.firebasestorage.app",
    "messagingSenderId":"421282137669",
    "appId":            "1:421282137669:web:e035ad7246c3923252c52c",
    "measurementId": "G-N6HTF73B3J"
}

firebase = pyrebase.initialize_app(firebase_config)
db = firebase.database()

# -------------------- Schemas --------------------
class IngredientAlt(BaseModel):
    ingredient: str
    alternatives: List[str] = []

class MealBlock(BaseModel):
    recipe: str                           # e.g., "Chicken Caesar Salad"
    ingredients_with_alternatives: List[IngredientAlt] = []

class CustomMealPlanRequest(BaseModel):
    # Each key is a meal section the user fills manually
    breakfast: Optional[MealBlock] = None
    lunch: Optional[MealBlock] = None
    dinner: Optional[MealBlock] = None
    snack: Optional[MealBlock] = None

    # Optional context
    predicted_calories: Optional[float] = None
    profile: Optional[Dict] = None
    note: Optional[str] = None

class CustomMealPlanSaveResponse(BaseModel):
    status: str
    id: str

class ValidationRequest(BaseModel):
    plan: CustomMealPlanRequest
    # either pass a disease list or rely on plan.profile flags (e.g., Diabetes=1, Hypertension=1)
    conditions: Optional[List[str]] = None     # ["Diabetes","Hypertension",...]

class ValidationWarning(BaseModel):
    meal_type: str
    disease: str
    severity: str  # "info" | "moderate" | "high"
    reasons: List[str] = []
    suggestions: List[str] = []

class ValidationResult(BaseModel):
    is_safe: bool
    warnings: List[ValidationWarning] = []

class RatingSetRequest(BaseModel):
    date: Optional[str] = None              # "YYYY-MM-DD"; server will default to today if missing
    meal_type: str                          # "Breakfast" | "Lunch" | "Dinner" | "Snack"
    rating: float                           # 1.0 - 5.0
    recipe: Optional[str] = None            # optional: recipe title shown in card
    plan_kind: Optional[str] = None         # "ai" or "custom" (optional)
    plan_id: Optional[str] = None           # custom plan id (optional)


class RecipeRequest(BaseModel):
    recipe: str

class UserProfile(BaseModel):
    Age: int
    Gender: str
    Height: int
    Weight: int
    Activity_Level: str
    Dietary_Preference: str
    Budget_Preferences: str
    Acne: int
    Diabetes: int
    Heart_Disease: int
    Hypertension: int
    Kidney_Disease: int
    Weight_Gain: int
    Weight_Loss: int

class CustomPreference(BaseModel):
    meal_type: str                    # "Breakfast" | "Lunch" | "Dinner" | "Snack"
    preferred_recipe: str             # free-text from user
    note: Optional[str] = None        # optional extra context
    selected_alternatives: Optional[Dict[str, str]] = None  # {ingredient: chosen_alt}
    predicted_calories: Optional[float] = None               # to keep context if you want
    profile: Optional[dict] = None    # optional snapshot of profile


DISEASE_RULES = {
    "Diabetes": {
        "triggers": [
            r"\bsugar\b", r"\bhoney\b", r"\bjaggery\b", r"\bsyrup\b",
            r"\bmolasses\b", r"\bsweetened\b", r"\bcondensed milk\b",
            r"\bwhite\s+rice\b", r"\bwhite\s+bread\b", r"\bmaida\b",
            r"\bcornflakes\b", r"\bbanana\b", r"\bdates?\b"
        ],
        "suggestions": [
            "Use non-nutritive sweetener or omit added sugar",
            "Prefer brown rice or quinoa over white rice",
            "Choose whole-grain bread instead of white",
            "Swap sweetened dairy for unsweetened/low-sugar options"
        ],
        "severity": "moderate"
    },
    "Hypertension": {
        "triggers": [
            r"\bsalt\b", r"\bsoy\s*sauce\b", r"\bpickles?\b",
            r"\bprocessed meat\b", r"\bbacon\b", r"\bsausage\b",
            r"\binstant noodles?\b", r"\bstock cube\b", r"\bbouillon\b"
        ],
        "suggestions": [
            "Reduce added salt; use herbs/spices",
            "Use low-sodium soy sauce/tamari",
            "Avoid processed meats"
        ],
        "severity": "moderate"
    },
    "Kidney Disease": {
        "triggers": [
            r"\bbananas?\b", r"\bpotatoes?\b", r"\btomatoes?\b",
            r"\bspinach\b", r"\bdairy\b", r"\bcheese\b", r"\bnuts?\b"
        ],
        "suggestions": [
            "Limit high-potassium foods (check with your renal dietitian)",
            "Prefer rice/corn-based options; moderate dairy and nuts"
        ],
        "severity": "info"
    },
    "Heart Disease": {
        "triggers": [
            r"\bfried\b", r"\bbutter\b", r"\bghee\b", r"\bcream\b",
            r"\bpalm oil\b", r"\bprocessed meat\b"
        ],
        "suggestions": [
            "Use baking/grilling/steaming instead of frying",
            "Prefer olive/canola oil; limit butter/ghee",
            "Avoid processed meats"
        ],
        "severity": "moderate"
    },
}

# -------------------- Helpers --------------------
def _collect_ingredients(block: Optional[MealBlock]) -> List[str]:
    if not block: return []
    items = []
    for row in block.ingredients_with_alternatives:
        items.append(row.ingredient or "")
        items.extend(row.alternatives or [])
    return [i.strip().lower() for i in items if i and i.strip()]

def _conditions_from_profile(profile: Optional[Dict], fallback: Optional[List[str]]) -> List[str]:
    # Allow both {Diabetes:1} flags or explicit list
    if fallback: return fallback
    conds = []
    if not profile: return conds
    for k, v in profile.items():
        if isinstance(v, (int, float)) and v == 1:
            conds.append(str(k))
        elif isinstance(v, str) and v.lower() in ("true", "yes", "1"):
            conds.append(str(k))
    return conds

def validate_with_rules(plan: CustomMealPlanRequest, conditions: List[str]) -> ValidationResult:
    warnings: List[ValidationWarning] = []
    sections = {
        "Breakfast": plan.breakfast,
        "Lunch": plan.lunch,
        "Dinner": plan.dinner,
        "Snack": plan.snack,
    }
    for disease in conditions:
        rules = DISEASE_RULES.get(disease)
        if not rules: continue
        pats = [re.compile(p, flags=re.I) for p in rules["triggers"]]
        for meal_type, block in sections.items():
            if not block: continue
            ings = " | ".join(_collect_ingredients(block))
            hits = [p.pattern.strip("r") for p in pats if p.search(ings)]
            if hits:
                warnings.append(ValidationWarning(
                    meal_type=meal_type,
                    disease=disease,
                    severity=rules["severity"],
                    reasons=[f"Contains or suggests: {', '.join(hits[:5])}"],
                    suggestions=rules["suggestions"]
                ))
    is_safe = len([w for w in warnings if w.severity in ("moderate","high")]) == 0
    return ValidationResult(is_safe=is_safe, warnings=warnings)


def get_meal_plan_for_calorie(
    calorie_target: float,
    dietary_preference: str | None = None,
    budget_preference: str | None = None,
):
    # Build a semantically-informative query so the embedding also leans the right way
    query = f"A healthy meal plan for a person needing {calorie_target} calories"

    if dietary_preference:
        pref = _canon_pref(dietary_preference)
        if pref == "veg":    query += " that is vegetarian"
        elif pref == "vegan": query += " that is vegan"
        elif pref == "non-veg": query += " that includes meat"

    if budget_preference:
        bp = _canon_budget(budget_preference)
        query += {
            "low": " that is budget-friendly and affordable",
            "medium": " that balances cost and quality",
            "high": " that uses premium ingredients",
        }.get(bp, f" that fits a {bp} budget")

    q_emb = meal_suggestion_model.encode([query])
    sims = cosine_similarity(q_emb, meal_embeddings)[0]

    # ------- Build masks -------
    n = len(df)
    mask_diet = np.ones(n, dtype=bool)
    mask_budget = np.ones(n, dtype=bool)

    # Dietary Preference mask (if column present)
    if dietary_preference and "Dietary Preference" in df.columns:
        pref_col = df["Dietary Preference"].apply(_canon_pref)
        mask_diet = (pref_col == _canon_pref(dietary_preference)).values

    # Budget Preference mask (if column present)
    if budget_preference and "Budget Preferences" in df.columns:
        bud_col = df["Budget Preferences"].apply(_canon_budget)
        mask_budget = (bud_col == _canon_budget(budget_preference)).values

    # Try strict: both masks
    combined = mask_diet & mask_budget
    sims_try = sims.copy()

    def _pick_best(active_mask):
        if not active_mask.any():
            return None
        s = sims.copy()
        s[~active_mask] = -np.inf
        idx = int(np.argmax(s))
        return idx if np.isfinite(s[idx]) else None

    best_idx = _pick_best(combined)

    # If nothing matched, relax stepwise: budget-only -> diet-only -> global best
    if best_idx is None and budget_preference:
        best_idx = _pick_best(mask_budget)
    if best_idx is None and dietary_preference:
        best_idx = _pick_best(mask_diet)
    if best_idx is None:
        best_idx = int(np.argmax(sims))  # final fallback

    return df.iloc[best_idx][[
        "Breakfast Suggestion", "Lunch Suggestion",
        "Dinner Suggestion", "Snack Suggestion"
    ]]


def fetch_ingredients_for_recipe(recipe_name: str) -> list[str]:
    if not recipe_name:
        return []
    name = str(recipe_name).strip()

    # First try CSV (case-insensitive)
    subset = ingredient_df[ingredient_df['Recipe'].str.lower() == name.lower()]
    if not subset.empty:
        return subset['Ingredient'].dropna().astype(str).str.strip().tolist()

    # Fallback to hardcoded map (case-sensitive key; try exact, then case-insensitive scan)
    if name in RECIPE_FALLBACK_MAP:
        return RECIPE_FALLBACK_MAP[name]
    for k, v in RECIPE_FALLBACK_MAP.items():
        if k.lower() == name.lower():
            return v
    return []


def fetch_alternatives_for_recipe(recipe_name: str) -> list[dict]:
    """
    Builds a list like:
    [
      {"ingredient": "X", "alternatives": ["A1","A2","A3"]},
      ...
    ]
    using Alternative_1..3 columns if present.
    """
    results = []
    if not recipe_name:
        return results

    name = str(recipe_name).strip().lower()
    subset = ingredient_df[ingredient_df['Recipe'].str.lower() == name]
    if subset.empty:
        return results

    alt_cols = [c for c in ['Alternative_1', 'Alternative_2', 'Alternative_3'] if c in subset.columns]
    for _, row in subset.iterrows():
        alts = []
        for c in alt_cols:
            v = row.get(c, None)
            if pd.notna(v) and str(v).strip():
                alts.append(str(v).strip())
        results.append({
            "ingredient": str(row['Ingredient']).strip(),
            "alternatives": alts
        })
    return results


# optional GPT validation
OPENAI_KEY = os.getenv("OPENAI_API_KEY")

SAVE_GPT_ING_TO_CSV = os.getenv("SAVE_GPT_ING_TO_CSV", "1") not in {"0", "false", "False", ""}

def validate_with_gpt(plan: CustomMealPlanRequest, conditions: List[str]) -> Optional[ValidationResult]:
    if not OPENAI_KEY:
        return None
    try:
        from openai import OpenAI
        client = OpenAI(api_key=OPENAI_KEY)

        schema = {
            "name": "MealPlanValidation",
            "strict": True,
            "schema": {
                "type": "object",
                "properties": {
                    "is_safe": {"type": "boolean"},
                    "warnings": {
                        "type": "array",
                        "items": {
                            "type": "object",
                            "properties": {
                                "meal_type": {"type": "string"},
                                "disease": {"type": "string"},
                                "severity": {"type": "string", "enum": ["info","moderate","high"]},
                                "reasons": {"type": "array", "items": {"type": "string"}},
                                "suggestions": {"type": "array", "items": {"type": "string"}},
                            },
                            "required": ["meal_type","disease","severity"]
                        }
                    }
                },
                "required": ["is_safe","warnings"]
            }
        }

        user_payload = {
            "conditions": conditions,
            "plan": json.loads(CustomMealPlanRequest.model_dump_json(plan))
        }
        print(user_payload)

        system_msg = "You are a licensed dietitian. Evaluate meal plans by meal for listed conditions. Return only JSON per schema."
        user_msg = f"Schema: {json.dumps(schema['schema'])}\nData: {json.dumps(user_payload, ensure_ascii=False)}"

        # 1) Try Responses API + structured outputs (new SDKs)
        try:
            resp = client.responses.create(
                model=os.getenv("MEAL_RISK_MODEL", "gpt-4o-mini"),
                input=[{"role": "system", "content": system_msg},
                       {"role": "user", "content": user_msg}],
                response_format={"type": "json_schema", "json_schema": schema},
            )
            try:
                text = resp.output_text  # convenient on newer SDKs
            except Exception:
                # safest generic extraction:
                text = json.dumps(getattr(resp, "output", {}), default=str)
            data = json.loads(text)

        # 2) Fallback: Chat Completions JSON mode (older SDKs don’t support response_format in Responses)
        except TypeError:
            chat = client.chat.completions.create(
                model=os.getenv("MEAL_RISK_MODEL", "gpt-4o-mini"),
                response_format={"type": "json_object"},
                messages=[
                    {"role": "system", "content": system_msg},
                    {"role": "user", "content": user_msg},
                ],
            )
            data = json.loads(chat.choices[0].message.content)

        warnings = [ValidationWarning(**w) for w in data.get("warnings", [])]
        return ValidationResult(is_safe=bool(data.get("is_safe", True)), warnings=warnings)

    except Exception as e:
        print(f"GPT validation failed: {e}")
        return None

def _today_str():
    return _dt.date.today().isoformat()

# To scope per-user later, change path to f"users/{uid}/ratings/..."
def _ratings_path(date_str: str) -> str:
    return f"ratings/{date_str}"

def _canon_pref(x: str) -> str:
    if not isinstance(x, str):
        return ""
    s = x.strip().lower()
    # map common variants
    if s in {"veg", "vegetarian"}: return "veg"
    if s in {"non-veg", "non veg", "nonvegetarian", "non vegetarian", "omnivore"}: return "non-veg"
    if s in {"vegan"}: return "vegan"
    return s

def _norm(s: str) -> str:
    return (s or "").strip()

def _dedup_keep_order(xs: List[str]) -> List[str]:
    seen = set()
    out = []
    for x in xs:
        x = _norm(x)
        if not x:
            continue
        k = x.lower()
        if k in seen:
            continue
        seen.add(k)
        out.append(x)
    return out

def _clean_alt_list(ingredient: str, alts: List[str]) -> List[str]:
    # remove empties, duplicates, and the original ingredient
    ing_key = ingredient.strip().lower()
    cleaned = [a for a in _dedup_keep_order(alts) if a.strip().lower() != ing_key]
    # cap at 3
    return cleaned[:3]


def _gpt_ingredients(recipe_name: str) -> Optional[List[Dict[str, List[str]]]]:
    if not OPENAI_KEY:
        return None
    try:
        from openai import OpenAI
        client = OpenAI(api_key=OPENAI_KEY)

        system_msg = (
            "You are a culinary assistant. For the given dish name, return a canonical ingredient "
            "list (no quantities) and up to three common alternatives for each ingredient. "
            "Use simple, widely available items. Output ONLY JSON."
        )
        schema = {
            "type": "object",
            "properties": {
                "recipe": {"type": "string"},
                "items": {
                    "type": "array",
                    "items": {
                        "type": "object",
                        "properties": {
                            "ingredient": {"type": "string"},
                            "alternatives": {
                                "type": "array",
                                "items": {"type": "string"},
                                "maxItems": 3
                            }
                        },
                        "required": ["ingredient"]
                    }
                }
            },
            "required": ["recipe", "items"]
        }
        user_msg = json.dumps({
            "dish": recipe_name,
            "format": {
                "recipe": "string",
                "items": [{"ingredient": "string", "alternatives": ["string","string","string"]}]
            }
        })

        # Try Responses API with JSON schema
        try:
            resp = client.responses.create(
                model=os.getenv("GPT_ING_MODEL", "gpt-4o-mini"),
                input=[
                    {"role": "system", "content": system_msg},
                    {"role": "user", "content": user_msg},
                ],
                response_format={"type": "json_schema", "json_schema": {"name":"IngredientSchema","schema":schema,"strict":True}},
            )
            # robust extraction across SDK variants
            text = getattr(resp, "output_text", None)
            if not text:
                text = json.dumps(getattr(resp, "output", {}), default=str)
            data = json.loads(text)

        except TypeError:
            # Fallback to Chat Completions JSON mode
            chat = client.chat.completions.create(
                model=os.getenv("GPT_ING_MODEL", "gpt-4o-mini"),
                response_format={"type": "json_object"},
                messages=[
                    {"role":"system","content": system_msg},
                    {"role":"user","content": user_msg},
                ],
            )
            data = json.loads(chat.choices[0].message.content)

        items = data.get("items", [])
        out = []
        for it in items:
            ing = _norm(it.get("ingredient", ""))
            if not ing:
                continue
            alts = it.get("alternatives", []) or []
            out.append({"ingredient": ing, "alternatives": _clean_alt_list(ing, alts)})
        return out or None

    except Exception as e:
        logging.warning(f"GPT ingredient generation failed for {recipe_name!r}: {e}")
        return None

# Ensure you have this global loaded once (you already do above in your file)
# ingredient_df = pd.read_csv("all_recipe_ingredients.csv")

def get_ingredients_with_alts(recipe_name: str) -> Optional[List[Dict[str, List[str]]]]:
    global ingredient_df  # 👈 declare once at the very top
    rnorm = recipe_name.strip().lower()

    # 1) CSV lookup (case-insensitive)
    try:
        rows = ingredient_df[ingredient_df["Recipe"].str.lower() == rnorm]
        if not rows.empty:
            out = []
            for _, row in rows.iterrows():
                ing = _norm(row.get("Ingredient", ""))
                a1 = _norm(row.get("Alternative_1", ""))
                a2 = _norm(row.get("Alternative_2", ""))
                a3 = _norm(row.get("Alternative_3", ""))
                alts = _clean_alt_list(ing, [a1, a2, a3])
                out.append({"ingredient": ing, "alternatives": alts})
            if out:
                return out
    except Exception as e:
        logging.warning(f"CSV ingredient lookup failed: {e}")

    # 2) GPT fallback
    gpt_items = _gpt_ingredients(recipe_name)
    if not gpt_items:
        return None

    # 3) Optionally persist GPT result to CSV and refresh in-memory df
    if SAVE_GPT_ING_TO_CSV:
        try:
            new_rows = []
            for it in gpt_items:
                ing = it["ingredient"]
                alts = it.get("alternatives", [])
                new_rows.append({
                    "Recipe": recipe_name,
                    "Ingredient": ing,
                    "Alternative_1": alts[0] if len(alts) > 0 else "",
                    "Alternative_2": alts[1] if len(alts) > 1 else "",
                    "Alternative_3": alts[2] if len(alts) > 2 else "",
                })

            df_new = pd.DataFrame(new_rows, columns=[
                "Recipe", "Ingredient", "Alternative_1", "Alternative_2", "Alternative_3"
            ])

            # Append to file with a correct header flag if file is empty/missing
            header_needed = not os.path.exists(INGREDIENTS_CSV_PATH) or os.path.getsize(INGREDIENTS_CSV_PATH) == 0
            df_new.to_csv(INGREDIENTS_CSV_PATH, mode="a", header=header_needed, index=False)

            # Refresh in-memory dataframe (fast: concat vs re-read disk)
            ingredient_df = pd.concat([ingredient_df, df_new], ignore_index=True)
        except Exception as e:
            logging.warning(f"Failed to persist GPT ingredients: {e}")

    return gpt_items

def _canon_budget(x: str) -> str:
    s = str(x or "").strip().lower()
    s = s.replace("-", " ").replace("_", " ")
    if s in {"low", "budget", "affordable", "economical", "cheap", "thrifty"}:
        return "low"
    if s in {"medium", "moderate", "standard", "mid", "mid range", "midrange", "average", "avg"}:
        return "medium"
    if s in {"high", "premium", "luxury", "expensive", "gourmet", "costly"}:
        return "high"
    return s

# -------------------- Public Endpoints --------------------
@app.post("/ratings/set")
def set_rating(req: RatingSetRequest):
    date_str = req.date or _today_str()
    node = {
        "rating": float(req.rating),
        "recipe": req.recipe or "",
        "plan_kind": req.plan_kind or "ai",
        "plan_id": req.plan_id or "",
        "ts_ms": int(_dt.datetime.utcnow().timestamp() * 1000),
    }
    # ratings/{YYYY-MM-DD}/{Breakfast|Lunch|Dinner|Snack}
    db.child(_ratings_path(date_str)).child(req.meal_type).set(node)
    return {"status": "ok", "date": date_str}

@app.get("/ratings/{date_str}")
def get_ratings(date_str: str):
    snap = db.child(_ratings_path(date_str)).get()
    raw = snap.val() or {}
    # Return compact map { "Breakfast": 4.5, ... }
    ratings: Dict[str, float] = {}
    for k, v in (raw.items() if isinstance(raw, dict) else []):
        try:
            ratings[k] = float(v.get("rating", 0))
        except Exception:
            pass
    return {"date": date_str, "ratings": ratings}

@app.post("/validate-meal-plan", response_model=ValidationResult)
def validate_meal_plan(req: ValidationRequest):
    conds = _conditions_from_profile(req.plan.profile, req.conditions)
    # Try GPT first, then heuristics
    gpt_result = validate_with_gpt(req.plan, conds)
    if gpt_result:
        return gpt_result
    return validate_with_rules(req.plan, conds)



@app.post("/custom-preference")
def save_custom_preference(pref: CustomPreference):
    payload = {
        "ts_ms": int(time.time() * 1000),
        "meal_type": pref.meal_type,
        "preferred_recipe": pref.preferred_recipe,
        "note": pref.note or "",
        "selected_alternatives": pref.selected_alternatives or {},
        "predicted_calories": pref.predicted_calories,
        "profile": pref.profile or {},
    }
    # you can also scope by user id: db.child(f"users/{uid}/custom_preferences").push(payload)
    res = db.child("custom_preferences").push(payload)
    return {"status": "ok", "id": res.get("name")}

@app.post("/get-ingredients")
def get_ingredients_endpoint(data: RecipeRequest):
    recipe_name = data.recipe.strip()
    items = get_ingredients_with_alts(recipe_name)
    if items:
        return {
            "recipe": recipe_name,
            "ingredients": [it["ingredient"] for it in items]
        }
    return {"error": "Recipe not found"}

@app.post("/get-recipe-alternatives")
def get_recipe_alternatives_endpoint(data: RecipeRequest):
    recipe_name = data.recipe.strip()
    items = get_ingredients_with_alts(recipe_name)
    if items:
        return {
            "recipe": recipe_name,
            "ingredients_with_alternatives": items
        }
    return {"error": "Recipe not found"}


@app.post("/custom-meal-plan", response_model=CustomMealPlanSaveResponse)
def save_custom_meal_plan(plan: CustomMealPlanRequest):
    # validate
    conds = _conditions_from_profile(plan.profile, None)
    validation = validate_with_gpt(plan, conds) or validate_with_rules(plan, conds)

    payload = {
        "ts_ms": int(time.time() * 1000),
        "predicted_calories": plan.predicted_calories,
        "profile": plan.profile or {},
        "note": plan.note or "",
        "meals": {
            "breakfast": plan.breakfast.dict() if plan.breakfast else None,
            "lunch": plan.lunch.dict() if plan.lunch else None,
            "dinner": plan.dinner.dict() if plan.dinner else None,
            "snack": plan.snack.dict() if plan.snack else None,
        },
        "validation": validation.model_dump(),
    }
    res = db.child("custom_meal_plans").push(payload)  # or users/{uid}/custom_meal_plans
    return CustomMealPlanSaveResponse(status="ok", id=res.get("name"))

@app.get("/custom-meal-plan/latest")
def get_latest_custom_meal_plan():
    # fetch last by ts_ms
    snap = db.child("custom_meal_plans").order_by_child("ts_ms").limit_to_last(1).get()
    if not snap.each():
        return {}
    node = snap.each()[0]
    data = node.val()
    data["id"] = node.key()
    return data

@app.get("/custom-meal-plans")
def list_custom_meal_plans(limit: int = 20):
    items = []
    try:
        # Preferred: indexed query
        snap = db.child("custom_meal_plans").order_by_child("ts_ms").limit_to_last(limit).get()
    except HTTPError as e:
        logging.warning("RTDB index missing for /custom_meal_plans.ts_ms; falling back. %s", e)
        # Fallback: fetch all, sort and slice (OK for small datasets; add pagination if it grows)
        snap = db.child("custom_meal_plans").get()

    if snap and snap.each():
        for node in snap.each():
            data = node.val()
            if isinstance(data, dict):
                data["id"] = node.key()
                items.append(data)

    # sort newest first and apply limit on server
    items.sort(key=lambda x: x.get("ts_ms", 0), reverse=True)
    return {"items": items[:limit]}

@app.get("/custom-meal-plan/{plan_id}")
def get_custom_meal_plan(plan_id: str):
    data = db.child("custom_meal_plans").child(plan_id).get().val()
    if not data:
        raise HTTPException(status_code=404, detail="Custom meal plan not found")
    data["id"] = plan_id
    return data

@app.delete("/custom-meal-plan/{plan_id}")
def delete_custom_meal_plan(plan_id: str):
    db.child("custom_meal_plans").child(plan_id).remove()
    return {"status": "ok"}

@app.put("/custom-meal-plan/{plan_id}", response_model=CustomMealPlanSaveResponse)
def update_custom_meal_plan(plan_id: str, plan: CustomMealPlanRequest):
    # load existing
    old = db.child("custom_meal_plans").child(plan_id).get().val()
    if not old:
        raise HTTPException(status_code=404, detail="Custom meal plan not found")

    conds = _conditions_from_profile(plan.profile or old.get("profile"), None)
    validation = validate_with_gpt(plan, conds) or validate_with_rules(plan, conds)

    # merge old + new (partial updates allowed)
    old_meals = old.get("meals", {})
    payload = {
        "ts_ms": old.get("ts_ms"),  # keep original created time
        "ts_ms_updated": int(time.time() * 1000),
        "predicted_calories": plan.predicted_calories if plan.predicted_calories is not None else old.get("predicted_calories"),
        "profile": plan.profile if plan.profile is not None else old.get("profile", {}),
        "note": plan.note if plan.note is not None else old.get("note", ""),
        "meals": {
            "breakfast": plan.breakfast.dict() if plan.breakfast is not None else old_meals.get("breakfast"),
            "lunch":     plan.lunch.dict()     if plan.lunch     is not None else old_meals.get("lunch"),
            "dinner":    plan.dinner.dict()    if plan.dinner    is not None else old_meals.get("dinner"),
            "snack":     plan.snack.dict()     if plan.snack     is not None else old_meals.get("snack"),
        },
        "validation": validation.model_dump(),
    }

    db.child("custom_meal_plans").child(plan_id).set(payload)
    return CustomMealPlanSaveResponse(status="ok", id=plan_id)

@app.post("/suggest-meal")
def suggest_meal(user: UserProfile):
    # Build model input
    userData = pd.DataFrame([{
        'Age': user.Age,
        'Gender': user.Gender,
        'Height': user.Height,
        'Weight': user.Weight,
        'Activity Level': user.Activity_Level,
        'Dietary Preference': user.Dietary_Preference,
        'Budget Preferences': user.Budget_Preferences,
        'Acne': user.Acne,
        'Diabetes': user.Diabetes,
        'Heart Disease': user.Heart_Disease,
        'Hypertension': user.Hypertension,
        'Kidney Disease': user.Kidney_Disease,
        'Weight Gain': user.Weight_Gain,
        'Weight Loss': user.Weight_Loss
    }])

    # Predict calories
    predicted_calories = float(model.predict(userData)[0])

    # Get best meal plan (Series of 4 items)
    suggestions_series = get_meal_plan_for_calorie(predicted_calories,
        dietary_preference=user.Dietary_Preference ,budget_preference=user.Budget_Preferences)

    # Normalize keys & look up ingredients + alternatives for each suggestion
    # Keys in your CSV: 'Breakfast Suggestion', etc.
    mapping = {
        "breakfast": 'Breakfast Suggestion',
        "lunch": 'Lunch Suggestion',
        "dinner": 'Dinner Suggestion',
        "snack": 'Snack Suggestion'
    }

    meals_block = {}
    for key, csv_col in mapping.items():
        recipe = str(suggestions_series[csv_col]).strip()
        ingredients = fetch_ingredients_for_recipe(recipe)
        alternatives = fetch_alternatives_for_recipe(recipe)
        meals_block[key] = {
            "recipe": recipe,
            "ingredients": ingredients,              # flat list
            "ingredients_with_alternatives": alternatives  # per-ingredient alternatives
        }

    # ---------- Save to Firebase Realtime Database ----------
    payload = {
        "ts_ms": int(time.time() * 1000),
        "predicted_calories": predicted_calories,
        "profile": user.dict(),
        "meals": meals_block
    }

    # Example path: /meal_suggestions/<auto_id>
    # If you want per-user paths, change to f"users/{USER_ID}/meal_suggestions"
    push_result = db.child("meal_suggestions").push(payload)
    firebase_id = push_result.get("name")  # auto-id from RTDB

    # Return original API result + firebase id
    xs =  {
        "predicted_calories": predicted_calories,
        "suggested_meals": {k: v["recipe"] for k, v in meals_block.items()},
        "ingredients": {k: v["ingredients"] for k, v in meals_block.items()},
        "ingredients_with_alternatives": {k: v["ingredients_with_alternatives"] for k, v in meals_block.items()},
        "firebase_id": firebase_id
    }

    print(xs)
    return {
        "predicted_calories": predicted_calories,
        "suggested_meals": {k: v["recipe"] for k, v in meals_block.items()},
        "ingredients": {k: v["ingredients"] for k, v in meals_block.items()},
        "ingredients_with_alternatives": {k: v["ingredients_with_alternatives"] for k, v in meals_block.items()},
        "firebase_id": firebase_id
    }

@app.get("/")
def read_root():
    return {"message": "Hello from FastAPI in Docker!"}
