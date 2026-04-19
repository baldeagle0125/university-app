import { useState } from "react";

export function LoginForm({ onLogin, loading, error }) {
  const [staffNumber, setStaffNumber] = useState("");
  const [password, setPassword] = useState("");

  return (
    <section className="login-panel">
      <p className="eyebrow">Admin Portal</p>
      <h1>University App</h1>
      <p>Sign in with an admin staff account. Live data will sync automatically after login.</p>
      <form
        onSubmit={(event) => {
          event.preventDefault();
          onLogin(staffNumber, password);
        }}
      >
        <label>
          Staff Number
          <input value={staffNumber} onChange={(e) => setStaffNumber(e.target.value)} required />
        </label>
        <label>
          Password
          <input
            type="password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
          />
        </label>
        <button type="submit" disabled={loading}>
          {loading ? "Signing in..." : "Sign in"}
        </button>
      </form>
      {error ? <p className="error">{error}</p> : null}
    </section>
  );
}
