// ------------------------------------------------------------------------
// DATABASE & COLLECTION SETUP
// ------------------------------------------------------------------------

// Lists all databases on the MongoDB server.
// Only shows databases that have at least one document.
show dbs;

// Switches to the "personal" database.
// MongoDB creates it lazily (only actually saves it when you insert data).
use personal;

// Explicitly creates a collection named "students".
// In MongoDB, collections are usually created automatically on first insert.
db.createCollection("students");

// Lists all collections in the current database.
show collections;

// Renames the "students" collection to "student".
db.students.renameCollection("student");


// ------------------------------------------------------------------------
// INSERT COMMANDS
// ------------------------------------------------------------------------

// Inserts one document. MongoDB auto-adds an _id (ObjectId) if not provided.
db.students.insertOne({ name: "ali", city: "karachi", age: 23 });

// Inserts multiple documents at once.
// Notice "asim" has no age — MongoDB is schema-less.
db.students.insertMany([
  { name: "ali", city: "karachi", age: 27 },
  { name: "asim", city: "lahore" }
]);


// ------------------------------------------------------------------------
// READ (FIND) COMMANDS
// ------------------------------------------------------------------------

// Returns all documents in the collection.
// Equivalent to: SELECT * FROM students
db.students.find();

// Filter: WHERE city = 'Karachi'
db.students.find({ city: "Karachi" });

// Filter: WHERE name = 'ali' AND age = 21
db.students.find({ name: "ali", age: 21 });

// Filter: WHERE city = 'karachi' OR city = 'lahore'
db.students.find({
  $or: [{ city: "karachi" }, { city: "lahore" }]
});

// Filter: WHERE id IN (101, 102, 103)
db.students.find({ _id: { $in: [101, 102, 103] } });

// Filter: WHERE city <> 'karachi'
db.students.find({ city: { $ne: "karachi" } });

// Filter: WHERE age > 20
db.students.find({ age: { $gt: 20 } });

// Pattern Match: WHERE name LIKE 'A%'
// Uses regex. /^a/ means starts with 'a'. Case-insensitive: /^a/i
db.students.find({ name: /^a/ });

// Sort: ORDER BY name ASC
// 1 = ascending, -1 = descending
db.students.find().sort({ name: 1 });

// Limit: LIMIT 5
db.students.find().limit(5);

// Count: COUNT(*)
db.students.countDocuments();


// ------------------------------------------------------------------------
// UPDATE COMMANDS
// ------------------------------------------------------------------------

// Updates the first matching document.
// $set updates only specified fields.
db.students.updateOne(
  { _id: 101 },
  { $set: { city: "Lahore" } }
);


// ------------------------------------------------------------------------
// DELETE COMMANDS
// ------------------------------------------------------------------------

// Deletes the first document where name is "ali".
db.students.deleteOne({ name: "ali" });


// ------------------------------------------------------------------------
// DROP COMMANDS
// ------------------------------------------------------------------------

// Deletes the entire current database.
db.dropDatabase();

// Deletes just the "students" collection.
db.students.drop();


// ------------------------------------------------------------------------
// AGGREGATION
// ------------------------------------------------------------------------

// Groups documents by city and counts students.
// Equivalent to: SELECT city, COUNT(*) as total FROM students GROUP BY city;
db.students.aggregate([
  { $group: { _id: "$city", total: { $sum: 1 } } }
]);

// Calculates the average age per city.
// Equivalent to: SELECT city, AVG(age) as avgAge FROM students GROUP BY city;
db.students.aggregate([
  { $group: { _id: "$city", avgAge: { $avg: "$age" } } }
]);