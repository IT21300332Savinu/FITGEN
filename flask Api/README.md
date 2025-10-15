# Flask ML Backend

This project is a Flask-based backend for running a machine learning model. It provides a RESTful API to interact with the model and make predictions based on input data.

## Project Structure

```
flask-ml-backend
├── app
│   ├── __init__.py
│   ├── routes.py
│   ├── model.py
│   └── utils.py
├── requirements.txt
├── config.py
├── run.py
└── README.md
```

## Setup Instructions

1. **Clone the repository:**
   ```
   git clone <repository-url>
   cd flask-ml-backend
   ```

2. **Create a virtual environment:**
   ```
   python -m venv venv
   ```

3. **Activate the virtual environment:**
   - On Windows:
     ```
     venv\Scripts\activate
     ```
   - On macOS/Linux:
     ```
     source venv/bin/activate
     ```

4. **Install the required packages:**
   ```
   pip install -r requirements.txt
   ```

## Usage

1. **Run the application:**
   ```
   python run.py
   ```

2. **Access the API:**
   The API will be available at `http://127.0.0.1:5000/`. You can use tools like Postman or curl to interact with the endpoints defined in `app/routes.py`.

## Endpoints

- **/predict**: This endpoint accepts input data and returns predictions from the machine learning model.

## Contributing

Feel free to submit issues or pull requests for improvements or bug fixes.