class FoodyLLM:
    def generate(self, prompt: str) -> str:
        if "No matching recipe found" in prompt:
            return "Chua tim thay mon phu hop voi rang buoc hien tai. Hay noi long calories, ngan sach hoac di ung."
        return (
            "He thong da ket hop hybrid search va RAG context de chon cac mon phu hop. "
            "Danh sach uu tien mon dung muc tieu dinh duong, tranh di ung va nam trong ngan sach."
        )
