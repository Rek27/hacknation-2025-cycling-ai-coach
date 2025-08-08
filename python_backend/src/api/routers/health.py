from fastapi import APIRouter, status

router = APIRouter(prefix=f"/temp/health", tags=["Health"])

@router.get("/", status_code=status.HTTP_200_OK)
async def health_check():
    return {"status": "ok"}
