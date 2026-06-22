import { useState } from "react";

import { login } from "../services/authService";

function Login() {
  const [username, setUsername] = useState("");

  const [password, setPassword] = useState("");

  async function handleLogin() {
    try {
      const data = await login(
        username,

        password
      );

      console.log(data);

      localStorage.setItem(
        "access_token",

        data.access_token
      );

      console.log("Token saved");
    } catch (error) {
      console.log(error);
    }
  }

  return (
    <div>
      <h1>Login Page</h1>

      <input
        type="text"
        placeholder="Username"
        onChange={(event) => setUsername(event.target.value)}
      />

      <br />

      <br />

      <input
        type="password"
        placeholder="Password"
        onChange={(event) => setPassword(event.target.value)}
      />

      <br />

      <br />

      <button onClick={handleLogin}>Login</button>

      <h3>{username}</h3>
    </div>
  );
}

export default Login;
