function log() { }

function MyButton() {
  return <button onClick={log}>I'm a button</button>;
}

export default function MyApp() {
  return (
    <div style="width: 100%; height: 100%;">
      <h1>Welcome to my app</h1>
      <MyButton />
    </div>
  );
}
