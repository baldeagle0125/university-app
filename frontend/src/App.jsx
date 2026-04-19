import { useMemo, useState } from "react";
import {
  createStaff,
  createStudent,
  clearToken,
  deleteStudent,
  getToken,
  listAssignments,
  listCardRequests,
  listFeedback,
  listStaff,
  listStudents,
  listTelemetry,
  loginStaff,
  processCardRequest,
  setToken,
  updateStaff,
} from "./api";

const VIEWS = [
  { key: "dashboard", label: "Dashboard" },
  { key: "card-requests", label: "Card Requests" },
  { key: "students", label: "Students" },
  { key: "assignments", label: "Assignments" },
  { key: "feedback", label: "Feedback" },
  { key: "telemetry", label: "Telemetry" },
  { key: "staff", label: "Staff" },
];

function LoginForm({ onLogin, loading, error }) {
  const [staffNumber, setStaffNumber] = useState("");
  const [password, setPassword] = useState("");

  return (
    <section className="login-panel">
      <h1>University Admin Portal</h1>
      <p>Sign in with an admin staff account.</p>
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

export default function App() {
  const [activeView, setActiveView] = useState("dashboard");
  const [token, setTokenState] = useState(getToken());
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState("");
  const [studentFilters, setStudentFilters] = useState({
    search: "",
    cardStatus: "",
    programCode: "",
  });
  const [studentCreate, setStudentCreate] = useState({
    studentNumber: "",
    firstName: "",
    lastName: "",
    email: "",
    password: "",
  });
  const [staffCreate, setStaffCreate] = useState({
    staffNumber: "",
    firstName: "",
    lastName: "",
    email: "",
    password: "",
    role: "staff",
  });
  const [assignmentFilters, setAssignmentFilters] = useState({
    status: "",
    studentNumber: "",
    title: "",
  });
  const [feedbackFilters, setFeedbackFilters] = useState({
    feedbackType: "",
    studentNumber: "",
  });
  const [telemetryFilters, setTelemetryFilters] = useState({
    eventName: "",
    eventCategory: "",
    studentNumber: "",
  });
  const [data, setData] = useState({
    cardRequests: [],
    students: [],
    assignments: [],
    feedback: [],
    telemetry: [],
    staff: [],
  });

  const signedIn = useMemo(() => Boolean(token), [token]);

  async function handleLogin(staffNumber, password) {
    setLoading(true);
    setError("");

    try {
      const response = await loginStaff(staffNumber.trim(), password);
      setToken(response.token);
      setTokenState(response.token);
      await refreshAll();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function refreshAll() {
    setLoading(true);
    setError("");

    try {
      const [cardRequests, students, assignments, feedback, telemetry, staff] = await Promise.all([
        listCardRequests(),
        listStudents(),
        listAssignments(),
        listFeedback(),
        listTelemetry(),
        listStaff(),
      ]);

      setData({ cardRequests, students, assignments, feedback, telemetry, staff });
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleProcessCard(id, status) {
    setLoading(true);
    setError("");

    try {
      await processCardRequest(id, status, "Processed in admin portal");
      const cardRequests = await listCardRequests();
      setData((current) => ({ ...current, cardRequests }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function refreshStudentsWithFilters() {
    setLoading(true);
    setError("");

    try {
      const query = new URLSearchParams();

      if (studentFilters.search.trim()) {
        query.set("search", studentFilters.search.trim());
      }
      if (studentFilters.cardStatus.trim()) {
        query.set("card_status", studentFilters.cardStatus.trim());
      }
      if (studentFilters.programCode.trim()) {
        query.set("program_code", studentFilters.programCode.trim());
      }

      const students = await listStudents(query.toString());
      setData((current) => ({ ...current, students }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleCreateStudent(event) {
    event.preventDefault();
    setLoading(true);
    setError("");

    try {
      await createStudent({
        student_number: studentCreate.studentNumber.trim(),
        first_name: studentCreate.firstName.trim(),
        last_name: studentCreate.lastName.trim(),
        email: studentCreate.email.trim(),
        password: studentCreate.password,
        card_status: "none",
      });

      setStudentCreate({
        studentNumber: "",
        firstName: "",
        lastName: "",
        email: "",
        password: "",
      });
      await refreshStudentsWithFilters();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleDeleteStudent(id) {
    setLoading(true);
    setError("");

    try {
      await deleteStudent(id);
      await refreshStudentsWithFilters();
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleCreateStaff(event) {
    event.preventDefault();
    setLoading(true);
    setError("");

    try {
      await createStaff({
        staff_number: staffCreate.staffNumber.trim(),
        first_name: staffCreate.firstName.trim(),
        last_name: staffCreate.lastName.trim(),
        email: staffCreate.email.trim(),
        password: staffCreate.password,
        role: staffCreate.role,
      });

      setStaffCreate({
        staffNumber: "",
        firstName: "",
        lastName: "",
        email: "",
        password: "",
        role: "staff",
      });

      const staff = await listStaff();
      setData((current) => ({ ...current, staff }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function handleToggleStaffActive(staffMember) {
    setLoading(true);
    setError("");

    try {
      await updateStaff(staffMember.id, { is_active: !staffMember.is_active });
      const staff = await listStaff();
      setData((current) => ({ ...current, staff }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function refreshAssignmentsWithFilters() {
    setLoading(true);
    setError("");

    try {
      const query = new URLSearchParams();

      if (assignmentFilters.status.trim()) {
        query.set("status", assignmentFilters.status.trim());
      }
      if (assignmentFilters.studentNumber.trim()) {
        query.set("student_number", assignmentFilters.studentNumber.trim());
      }
      if (assignmentFilters.title.trim()) {
        query.set("title", assignmentFilters.title.trim());
      }

      const assignments = await listAssignments(query.toString());
      setData((current) => ({ ...current, assignments }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function refreshFeedbackWithFilters() {
    setLoading(true);
    setError("");

    try {
      const query = new URLSearchParams();

      if (feedbackFilters.feedbackType.trim()) {
        query.set("feedback_type", feedbackFilters.feedbackType.trim());
      }
      if (feedbackFilters.studentNumber.trim()) {
        query.set("student_number", feedbackFilters.studentNumber.trim());
      }

      const feedback = await listFeedback(query.toString());
      setData((current) => ({ ...current, feedback }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  async function refreshTelemetryWithFilters() {
    setLoading(true);
    setError("");

    try {
      const query = new URLSearchParams();

      if (telemetryFilters.eventName.trim()) {
        query.set("event_name", telemetryFilters.eventName.trim());
      }
      if (telemetryFilters.eventCategory.trim()) {
        query.set("event_category", telemetryFilters.eventCategory.trim());
      }
      if (telemetryFilters.studentNumber.trim()) {
        query.set("student_number", telemetryFilters.studentNumber.trim());
      }

      const telemetry = await listTelemetry(query.toString());
      setData((current) => ({ ...current, telemetry }));
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  }

  if (!signedIn) {
    return (
      <main className="page">
        <LoginForm onLogin={handleLogin} loading={loading} error={error} />
      </main>
    );
  }

  return (
    <main className="page">
      <header className="topbar">
        <h1>Admin Portal</h1>
        <div className="actions">
          <button type="button" onClick={refreshAll} disabled={loading}>
            {loading ? "Refreshing..." : "Refresh"}
          </button>
          <button
            type="button"
            onClick={() => {
              clearToken();
              setTokenState("");
            }}
          >
            Sign out
          </button>
        </div>
      </header>

      <nav className="tabs">
        {VIEWS.map((view) => (
          <button
            key={view.key}
            className={view.key === activeView ? "active" : ""}
            onClick={() => setActiveView(view.key)}
            type="button"
          >
            {view.label}
          </button>
        ))}
      </nav>

      {error ? <p className="error">{error}</p> : null}

      {activeView === "dashboard" ? (
        <section className="grid">
          <article className="panel stat">
            <h3>Pending Card Requests</h3>
            <p>{data.cardRequests.length}</p>
          </article>
          <article className="panel stat">
            <h3>Students</h3>
            <p>{data.students.length}</p>
          </article>
          <article className="panel stat">
            <h3>Assignments</h3>
            <p>{data.assignments.length}</p>
          </article>
          <article className="panel stat">
            <h3>Staff Accounts</h3>
            <p>{data.staff.length}</p>
          </article>
        </section>
      ) : null}

      {activeView === "card-requests" ? (
        <section className="panel">
          <h2>Card Requests</h2>
          {data.cardRequests.map((request) => (
            <article className="card" key={request.id}>
              <p>
                <strong>{request.student_number}</strong> requested <strong>{request.request_type}</strong>
              </p>
              <p>{request.request_reason || "No reason"}</p>
              <div className="actions">
                <button type="button" onClick={() => handleProcessCard(request.id, "approved")}>
                  Approve
                </button>
                <button type="button" onClick={() => handleProcessCard(request.id, "rejected")}>
                  Reject
                </button>
              </div>
            </article>
          ))}
        </section>
      ) : null}

      {activeView === "students" ? (
        <section className="panel">
          <h2>Students</h2>
          <form
            className="filters"
            onSubmit={(event) => {
              event.preventDefault();
              refreshStudentsWithFilters();
            }}
          >
            <label>
              Search
              <input
                value={studentFilters.search}
                onChange={(event) =>
                  setStudentFilters((current) => ({ ...current, search: event.target.value }))
                }
                placeholder="name, email, or student number"
              />
            </label>
            <label>
              Card Status
              <input
                value={studentFilters.cardStatus}
                onChange={(event) =>
                  setStudentFilters((current) => ({ ...current, cardStatus: event.target.value }))
                }
                placeholder="active | expired | lost | requested | none"
              />
            </label>
            <label>
              Program Code
              <input
                value={studentFilters.programCode}
                onChange={(event) =>
                  setStudentFilters((current) => ({ ...current, programCode: event.target.value }))
                }
                placeholder="e.g. CS"
              />
            </label>
            <div className="actions">
              <button type="submit" disabled={loading}>
                {loading ? "Loading..." : "Apply"}
              </button>
              <button
                type="button"
                onClick={() => {
                  setStudentFilters({ search: "", cardStatus: "", programCode: "" });
                  setLoading(true);
                  setError("");
                  listStudents()
                    .then((students) => setData((current) => ({ ...current, students })))
                    .catch((err) => setError(err.message))
                    .finally(() => setLoading(false));
                }}
              >
                Reset
              </button>
            </div>
          </form>
          <form className="filters" onSubmit={handleCreateStudent}>
            <label>
              Student Number
              <input
                value={studentCreate.studentNumber}
                onChange={(event) =>
                  setStudentCreate((current) => ({ ...current, studentNumber: event.target.value }))
                }
                required
              />
            </label>
            <label>
              First Name
              <input
                value={studentCreate.firstName}
                onChange={(event) =>
                  setStudentCreate((current) => ({ ...current, firstName: event.target.value }))
                }
                required
              />
            </label>
            <label>
              Last Name
              <input
                value={studentCreate.lastName}
                onChange={(event) =>
                  setStudentCreate((current) => ({ ...current, lastName: event.target.value }))
                }
                required
              />
            </label>
            <label>
              Email
              <input
                type="email"
                value={studentCreate.email}
                onChange={(event) =>
                  setStudentCreate((current) => ({ ...current, email: event.target.value }))
                }
                required
              />
            </label>
            <label>
              Temp Password
              <input
                type="password"
                value={studentCreate.password}
                onChange={(event) =>
                  setStudentCreate((current) => ({ ...current, password: event.target.value }))
                }
                required
              />
            </label>
            <div className="actions">
              <button type="submit" disabled={loading}>
                {loading ? "Saving..." : "Create Student"}
              </button>
            </div>
          </form>
          <div className="stack">
            {data.students.map((student) => (
              <article className="card" key={student.id}>
                <p>
                  <strong>
                    {student.first_name} {student.last_name}
                  </strong>{" "}
                  ({student.student_number})
                </p>
                <p>{student.email}</p>
                <p>Card: {student.card_status}</p>
                <div className="actions">
                  <button type="button" onClick={() => handleDeleteStudent(student.id)}>
                    Delete
                  </button>
                </div>
              </article>
            ))}
          </div>
        </section>
      ) : null}
      {activeView === "assignments" ? (
        <section className="panel">
          <h2>Assignments</h2>
          <form
            className="filters"
            onSubmit={(event) => {
              event.preventDefault();
              refreshAssignmentsWithFilters();
            }}
          >
            <label>
              Status
              <select
                value={assignmentFilters.status}
                onChange={(event) =>
                  setAssignmentFilters((current) => ({ ...current, status: event.target.value }))
                }
              >
                <option value="">All</option>
                <option value="assigned">assigned</option>
                <option value="submitted">submitted</option>
                <option value="overdue">overdue</option>
              </select>
            </label>
            <label>
              Student Number
              <input
                value={assignmentFilters.studentNumber}
                onChange={(event) =>
                  setAssignmentFilters((current) => ({ ...current, studentNumber: event.target.value }))
                }
                placeholder="e.g. S202401"
              />
            </label>
            <label>
              Title Contains
              <input
                value={assignmentFilters.title}
                onChange={(event) =>
                  setAssignmentFilters((current) => ({ ...current, title: event.target.value }))
                }
                placeholder="keyword"
              />
            </label>
            <div className="actions">
              <button type="submit" disabled={loading}>
                {loading ? "Loading..." : "Apply"}
              </button>
            </div>
          </form>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Student</th>
                  <th>Title</th>
                  <th>Status</th>
                  <th>Due Date</th>
                  <th>Submitted</th>
                </tr>
              </thead>
              <tbody>
                {data.assignments.map((assignment) => (
                  <tr key={assignment.id}>
                    <td>{assignment.student_number}</td>
                    <td>{assignment.title}</td>
                    <td>{assignment.status}</td>
                    <td>{assignment.due_date ? new Date(assignment.due_date).toLocaleString() : "-"}</td>
                    <td>{assignment.submitted_at ? new Date(assignment.submitted_at).toLocaleString() : "-"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      ) : null}
      {activeView === "feedback" ? (
        <section className="panel">
          <h2>Feedback</h2>
          <form
            className="filters"
            onSubmit={(event) => {
              event.preventDefault();
              refreshFeedbackWithFilters();
            }}
          >
            <label>
              Feedback Type
              <select
                value={feedbackFilters.feedbackType}
                onChange={(event) =>
                  setFeedbackFilters((current) => ({ ...current, feedbackType: event.target.value }))
                }
              >
                <option value="">All</option>
                <option value="bug">bug</option>
                <option value="usability">usability</option>
                <option value="feature">feature</option>
              </select>
            </label>
            <label>
              Student Number
              <input
                value={feedbackFilters.studentNumber}
                onChange={(event) =>
                  setFeedbackFilters((current) => ({ ...current, studentNumber: event.target.value }))
                }
                placeholder="e.g. S202401"
              />
            </label>
            <div className="actions">
              <button type="submit" disabled={loading}>
                {loading ? "Loading..." : "Apply"}
              </button>
            </div>
          </form>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Student</th>
                  <th>Type</th>
                  <th>Title</th>
                  <th>Rating</th>
                  <th>Created</th>
                </tr>
              </thead>
              <tbody>
                {data.feedback.map((entry) => (
                  <tr key={entry.id}>
                    <td>{entry.student_number}</td>
                    <td>{entry.feedback_type}</td>
                    <td>{entry.title}</td>
                    <td>{entry.rating ?? "-"}</td>
                    <td>{entry.created_at ? new Date(entry.created_at).toLocaleString() : "-"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      ) : null}
      {activeView === "telemetry" ? (
        <section className="panel">
          <h2>Telemetry</h2>
          <form
            className="filters"
            onSubmit={(event) => {
              event.preventDefault();
              refreshTelemetryWithFilters();
            }}
          >
            <label>
              Event Name
              <input
                value={telemetryFilters.eventName}
                onChange={(event) =>
                  setTelemetryFilters((current) => ({ ...current, eventName: event.target.value }))
                }
                placeholder="e.g. screen_open"
              />
            </label>
            <label>
              Event Category
              <input
                value={telemetryFilters.eventCategory}
                onChange={(event) =>
                  setTelemetryFilters((current) => ({ ...current, eventCategory: event.target.value }))
                }
                placeholder="e.g. navigation"
              />
            </label>
            <label>
              Student Number
              <input
                value={telemetryFilters.studentNumber}
                onChange={(event) =>
                  setTelemetryFilters((current) => ({ ...current, studentNumber: event.target.value }))
                }
                placeholder="e.g. S202401"
              />
            </label>
            <div className="actions">
              <button type="submit" disabled={loading}>
                {loading ? "Loading..." : "Apply"}
              </button>
            </div>
          </form>
          <div className="table-wrap">
            <table>
              <thead>
                <tr>
                  <th>Student</th>
                  <th>Event</th>
                  <th>Category</th>
                  <th>Screen</th>
                  <th>Created</th>
                </tr>
              </thead>
              <tbody>
                {data.telemetry.map((event) => (
                  <tr key={event.id}>
                    <td>{event.student_number}</td>
                    <td>{event.event_name}</td>
                    <td>{event.event_category}</td>
                    <td>{event.screen_name || "-"}</td>
                    <td>{event.created_at ? new Date(event.created_at).toLocaleString() : "-"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      ) : null}
      {activeView === "staff" ? (
        <section className="panel">
          <h2>Staff</h2>
          <form className="filters" onSubmit={handleCreateStaff}>
            <label>
              Staff Number
              <input
                value={staffCreate.staffNumber}
                onChange={(event) =>
                  setStaffCreate((current) => ({ ...current, staffNumber: event.target.value }))
                }
                required
              />
            </label>
            <label>
              First Name
              <input
                value={staffCreate.firstName}
                onChange={(event) =>
                  setStaffCreate((current) => ({ ...current, firstName: event.target.value }))
                }
                required
              />
            </label>
            <label>
              Last Name
              <input
                value={staffCreate.lastName}
                onChange={(event) =>
                  setStaffCreate((current) => ({ ...current, lastName: event.target.value }))
                }
                required
              />
            </label>
            <label>
              Email
              <input
                type="email"
                value={staffCreate.email}
                onChange={(event) =>
                  setStaffCreate((current) => ({ ...current, email: event.target.value }))
                }
                required
              />
            </label>
            <label>
              Password
              <input
                type="password"
                value={staffCreate.password}
                onChange={(event) =>
                  setStaffCreate((current) => ({ ...current, password: event.target.value }))
                }
                required
              />
            </label>
            <label>
              Role
              <select
                value={staffCreate.role}
                onChange={(event) =>
                  setStaffCreate((current) => ({ ...current, role: event.target.value }))
                }
              >
                <option value="staff">staff</option>
                <option value="admin">admin</option>
              </select>
            </label>
            <div className="actions">
              <button type="submit" disabled={loading}>
                {loading ? "Saving..." : "Create Staff"}
              </button>
            </div>
          </form>
          <div className="stack">
            {data.staff.map((staffMember) => (
              <article className="card" key={staffMember.id}>
                <p>
                  <strong>
                    {staffMember.first_name} {staffMember.last_name}
                  </strong>{" "}
                  ({staffMember.staff_number})
                </p>
                <p>
                  {staffMember.email} - {staffMember.role} -
                  {staffMember.is_active ? " active" : " inactive"}
                </p>
                <div className="actions">
                  <button type="button" onClick={() => handleToggleStaffActive(staffMember)}>
                    Set {staffMember.is_active ? "Inactive" : "Active"}
                  </button>
                </div>
              </article>
            ))}
          </div>
        </section>
      ) : null}
    </main>
  );
}
