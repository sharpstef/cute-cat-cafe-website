-- Select Queries

/*
    Query to get all Beverages and their Ingredients.
    Used in the Admin/Beverages and Menu pages.
*/

SELECT b.beverageID, b.name, b.description, b.type, b.price, i.name AS ingredient
FROM Beverages b
LEFT JOIN BeverageIngredients bi ON b.beverageID = bi.beverageID
JOIN Ingredients i ON bi.ingredientID = i.ingredientID
ORDER BY b.name ASC;

/*
    Query to get all Beverages and their Ingredients that have a given ingredient.
    Used in the Menu page.
*/
SELECT b.beverageID, b.name, b.description, b.type, b.price, i.name AS ingredient
FROM Beverages b
JOIN BeverageIngredients bi ON b.beverageID = bi.beverageID
JOIN Ingredients i ON bi.ingredientID = i.ingredientID
WHERE i.name = :ingredient
ORDER BY b.name ASC;

/*
    Query to get all Cats and their assigned Rooms.
    Used by the Admin/Cats page. 
*/

SELECT c.catID, c.name, c.breed, c.age, c.dateAdmitted, c.adopted, r.name AS room
FROM Cats c
LEFT JOIN Rooms r ON c.roomID = r.roomID
ORDER BY c.name ASC;

/*
    Query to get Cats that are adoptable
    and not currently assigned to a room. 
*/
SELECT c.catID, c.name as cat
FROM Cats c
WHERE c.roomID IS NULL
AND c.adopted = 0
ORDER BY c.name ASC;

/*
    Query to find a customer in Customers given a 
    provided email. Used for the login page.
    : used to indicated user provided value
*/

SELECT * 
FROM Customers
WHERE email = :email;

/*
    Query to find a customer in Customers given a 
    provided id from session. Used for logout.
    : used to indicated user provided value
*/
SELECT * 
FROM Customers 
WHERE customerID = :customerID;

/*
    Query to get all Ingredients.
    Used by the Admin/Ingredients page.
*/

SELECT *
FROM Ingredients
ORDER BY name ASC;

/*
    Query to get all Orders for a given Customer.
    Returns the list of OrderItems with the details of
    the order. 

    Used for the Order History section of the Account page.

    : indicates the system stored customerID for querying
*/

SELECT o.orderID, o.purchaseTime, o.totalAmount, o.complete, b.name, oi.quantity, oi.status
FROM Orders o
JOIN OrderItems oi ON o.orderID = oi.orderID
JOIN Beverages b ON oi.beverageID = b.beverageID
WHERE o.customerID = :customerID;

/*
    Query to get all reservations for a given Customer.
    Returns all reservations with the room name from Rooms.

    Used for the Reservation History section of the Account page.

    : indicates the system stored customerID for querying
*/

SELECT r.reservationID, Rooms.name, r.totalFee, r.reservationStart, r.reservationEnd
FROM Reservations r 
JOIN Rooms ON r.roomID = Rooms.roomID 
WHERE r.customerID = :customerID;

/*
    Query to find all Rooms and their associated Cats.
    Used by the Admin/Rooms page. 
    Used by the Reservations page when completing a booking.

    : used to indicated user provided value
*/

SELECT r.roomID, r.name, r.roomDescription, r.reservable, r.fee, c.name AS cat
FROM Rooms r
LEFT JOIN Cats c ON c.roomID = r.roomID
ORDER BY r.name ASC;

/*
    Query to get empty rooms for assigning cats.
*/
SELECT r.roomID, r.name as room
FROM Rooms r
WHERE r.catID IS NULL
ORDER BY r.name ASC;

/*
    Query to get all rooms that are not booked for a given date/time.

    : indicates user provided dateTime
*/

SELECT r.roomID, r.name, r.roomDescription, r.fee, c.name AS cat
FROM Rooms r
JOIN Cats c ON c.catID = r.catID
WHERE r.reservable = 1
AND r.roomID NOT IN (
    SELECT roomID
    FROM Reservations 
    WHERE reservationStart 
    BETWEEN ?
    AND ?
    AND reservationEnd 
    BETWEEN ?
    AND ?
)
ORDER BY r.name ASC;


-- Insert Queries

/*
    Queries to add a new row to the Beverages and BeverageIngredients tables
    : used to indicated user or system provided value
*/

INSERT INTO Beverages (name, description, type, price)
VALUES 
(:name, :description, :type, :price);

INSERT INTO BeverageIngredients (beverageID, ingredientID)
VALUES
(:beverageID, :ingredientID);

/*
    Query to add a new row to the Cats table
    : used to indicate user or system provided value
    All cats start with a NULL for roomID
*/

INSERT INTO Cats (name, breed, age, dateAdmitted, adopted)
VALUES
(:name, :breed, :age, :date, 0);

/* 
   Query to add a new row to the Customers table
   : used to indicated user or system provided value
   hash and salt are generated by the application 
*/

INSERT INTO Customers (firstName, lastName, email, password, salt, member, isAdmin)
VALUES
(:fName, :lName, :email, :hash, :salt, :member, :admin);

/*
    Query to add a new row to the Ingredients table
    : used to indicate user or system provided value
*/

INSERT INTO Ingredients (name)
VALUES 
(:name);

/*
    Queries to add a new row to the Orders and OrderItems tables
    : used to indicate user or system provided value
*/

INSERT INTO Orders (purchaseTime, totalAmount, complete, customerID)
VALUES 
(:purchaseTime, :totalAmount, :complete, :customerID);

INSERT INTO OrderItems (orderID, beverageID, quantity, status)
VALUES
(:orderID, (SELECT beverageID FROM Beverages WHERE name=:beverage), :quantity, :status);

/*
    Queries to add a new row to the Reservations table
    : used to indicate user or system provided value
*/

INSERT INTO Reservations (customerID, roomID, totalFee, reservationStart, reservationEnd)
VALUES
(:customerID, :roomID, :totalFee, :reservationStart, :reservationEnd);

/*
    Query to add a new row to the Rooms table
    : used to indicate user or system provided value
    All rooms start with a NULL for catID
*/

INSERT INTO Rooms (name, roomDescription, reservable, fee)
VALUES
(:name, :description, 0, :fee);


-- Update Queries

/* 
    Query to update data in the Beverages table
    : used to indicate user or system provided value
*/

UPDATE Beverages
SET name = :name, description = :description, type = :type, price = :price
WHERE beverageID = :condition;

/*
    Query to update cat data when a new room is 
    added and there is a cat specified in the form.
    Used by the Room form.
*/

UPDATE Cats 
SET roomID = (
    SELECT roomID 
    FROM Rooms 
    WHERE name = :room) 
WHERE catID = :catID;

/*
    Query to update data in the Ingredients table
    : used to indicate user or system provided value
*/

UPDATE Ingredients
SET name = :name
WHERE ingredientID = :condition;

/*
    Query to update room data when a new cat is 
    added and there is a room specified in the form.
    Used by the Cat form.
*/

UPDATE Rooms
SET catID = :cat, reservable = 1
WHERE roomID = :roomID;


-- Delete Queries

/* 
    Query to delete existing data from the Beverages table
    Delete cascades to BeverageIngredients
    Delete cascades to OrderItems
    : used to indicate system provided value (id is stored as hidden in page)
*/

DELETE FROM Beverages WHERE beverageId = :condition;

/* 
    Query to remove an Ingredient linked to a Beverage
    : used to indicate user and system provided values
*/
DELETE FROM BeverageIngredients 
WHERE beverageID = :condition;

/* 
    Query to delete existing data from the Cats table
    Delete cascades a NULL to Rooms for catID
    : used to indicate system provided value (id is stored as hidden in page)
*/

DELETE FROM Cats WHERE catID = :condition;


/* 
    Query to delete existing data from the Ingredients table
    Delete cascades to BeverageIngredients
    : used to indicate system provided value (id is stored as hidden in page)
*/

DELETE FROM Ingredients WHERE ingredientId = :condition;

/* 
    Query to delete existing data from the Reservations table
    : used to indicate system provided value (id is stored as hidden in page)
*/

DELETE FROM Reservations WHERE reservationID = :condition;

/* 
    Query to delete existing data from the Rooms table
    Delete cascades a NULL to Cats for roomID
    : used to indicate system provided value (id is stored as hidden in page)
*/

DELETE FROM Rooms WHERE roomID = :condition;
