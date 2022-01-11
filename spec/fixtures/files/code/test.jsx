function getGreeting(user) {
  if (user) {
    return <h1>Hello, {formatName(user)}!</h1>;
  }
  return <h1>Hello, Stranger.</h1>;
}

const element = (
  <div>
    <h1>Hello!</h1>
    <h2>Good to see you here.</h2>
  </div>
);

const title = response.potentiallyMaliciousInput;
// This is safe:
const element = <h1>{title}</h1>;

/*
 * this
 * is
 * a multi
 * line
 * comment */
class Test {
  sayHello() {
    return 'Hello'; // Single line comment
  }
}
