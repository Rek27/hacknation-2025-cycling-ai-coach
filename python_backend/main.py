import uvicorn
from dotenv import load_dotenv
from src.app import app

load_dotenv(override=True, dotenv_path="../.env")

if __name__ == "__main__":
    app = app()
    uvicorn.run(app, host="0.0.0.0", port=8001)