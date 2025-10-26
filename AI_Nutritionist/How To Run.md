Install everything in requirements.txt file

    go the project folder ( when running the command you should be in the same folder
    that txt file lives in )

    pip install -r requirements.txt

    pip install pyrebase4

    pip install openai

    pip install python-dotenv

    if by any chance the backend did not connect to your frontend
    ( there is a high chance that the frontend points to a different ip )

    you can get your ipv4 address using ipconfig 
    simply type ipconfig in powershell or command prompt and then get the IPv4 Address
    ex - 192.168.1.8

    then change that the ip address in frontend meal_suggestions_service.dart file 

    This line -> final _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000'));

    this is in lib/ai_nutritionist/services/meal_suggestions_service.dart

    look at line 4 - its hard to miss
    
    if you follow these steps you will succeed in starting and connecting the server 
    
    below is server starting command 

    uvicorn main_new:app --host 0.0.0.0 --port 8000 --reload   




