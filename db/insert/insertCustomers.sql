-- Query to add a new row to the Customers table
-- : used to indicated user or system provided value
-- hash and salt are generated by the application

INSERT INTO Customers (firstName, lastName, email, password, salt, member, isAdmin)
VALUES
(:fName, :lName, :email, :hash, :salt, :member, :admin;