import axios from "axios";

const API_URL = "http://localhost:8000";

export async function login(
  username,

  password
) {
  const response = await axios.post(
    `${API_URL}/api/v1/auth/login`,

    new URLSearchParams({
      username,

      password,
    }),

    {
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    }
  );

  return response.data;
}
