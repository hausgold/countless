interface User {
  name: string;
  id: number;
}

class UserAccount {
  name: string;
  id: number;

  constructor(name: string, id: number) {
    this.name = name;
    this.id = id;
  }
}

const user: User = new UserAccount("Murphy", 1);

/** This is a description of the getAdminUser function. */
function getAdminUser(): User {
  //...
}

/**
 * Delete a user.
 *
 * @param {User} user
 * @returns {User}
 */
function deleteUser(user: User): User {
  // ...
}
