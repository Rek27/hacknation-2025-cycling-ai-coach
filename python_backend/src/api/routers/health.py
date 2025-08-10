from fastapi import APIRouter, status

router = APIRouter(prefix=f"/temp/health", tags=["Health"])

@router.get("/", status_code=status.HTTP_200_OK)
async def health_check():
    """Simple health check endpoint to verify the API is running."""
    return {"info": "test check"}
