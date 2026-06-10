from fastapi import FastAPI, HTTPException, File, UploadFile, Form, Depends
from app.schemas import PostResponce
from app.db import Post, create_db_and_tables, get_async_session
from sqlalchemy.ext.asyncio import AsyncSession # type: ignore[import]
from contextlib import asynccontextmanager
from sqlalchemy import select #type: ignore[import]

@asynccontextmanager
async def lifespan(app: FastAPI):
    await create_db_and_tables()
    yield

app = FastAPI(lifespan=lifespan)

@app.post("/upload)")
async def upload_file(
    file: UploadFile = File(...),
    caption: str = Form(...),
    session: AsyncSession = Depends(get_async_session)
):
    post = Post(
        caption=caption,
        url = "dummyurl",
        file_type = "photo",
        file_name = "dummy name"
    )
    session.add(post)
    await session.commit()
    await session.refresh(post)
    return post

@app.get("/feed")
async def get_feed(
    session: AsyncSession = Depends(get_async_session)
):
    result = await session.execute(select(Post).order_by(Post.created_at.desc())) 
     #"SELECT * FROM posts ORDER BY created_at DESC"
    posts = [row[0] for row in result.all()]
    posts_response = []
    for post in posts:
        post_response = Post(
            id=post.id,
            caption=post.caption,
            url=post.url,
            file_type=post.file_type,
            file_name=post.file_name,
            created_at=post.created_at.isoformat()
        )
        posts_response.append(post_response)
    return posts























'''
test_posts = {
    1: {"title": "First Post", "content": "This is the first post"},
    2: {"title": "Second Post", "content": "This is the second post"},
    3: {"title": "Third Post", "content": "This is the third post"},
    4: {"title": "Fourth Post", "content": "This is the fourth post"}
}

@app.get("/posts")
def get_all_posts(Limit: int = None):
    if Limit:
        return list(test_posts.values())[:Limit]
    return test_posts

@app.get("/posts/{id}")
def get_post(id: int)-> PostResponce:
    if id not in test_posts:
        raise HTTPException(status_code=404, detail="Post not found")
    return test_posts[id]

@app.post("/posts")
def create_post(post: PostResponce) -> PostResponce:
    new_post =  {"title": post.title, "content": post.content}
    test_posts[max(test_posts.keys())+1] = new_post
    return new_post
'''    
