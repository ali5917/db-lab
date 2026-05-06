// ------------------------------------------------------------------------
// DATABASE & COLLECTION SETUP
// ------------------------------------------------------------------------

// Lists all databases that have at least one document.
show dbs;

// Switches to the "mydb" database.
// MongoDB creates it lazily (only actually saves it when you insert data).
use mydb;

// creates a collection named "students".
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

// Insert with a custom _id (no auto-generated ObjectId).
db.students.insertOne({ _id: 101, name: "sara", city: "islamabad", age: 22 });

// Inserts multiple documents at once.
// Notice "asim" has no age — MongoDB is schema-less.
db.students.insertMany([
  { name: "ali", city: "karachi", age: 27 },
  { name: "asim", city: "lahore" },
  { name: "hina", city: "karachi", age: 24 },
  { name: "usman", city: "islamabad", age: 25 }
]);


// ------------------------------------------------------------------------
// READ (FIND) COMMANDS
// ------------------------------------------------------------------------

// Returns all documents in the collection.
// Equivalent to: SELECT * FROM students
db.students.find();

// Filter: WHERE city = 'Karachi'
db.students.find({ city: "karachi" });

// Find one document (returns the first match, not an array)
db.students.findOne({ city: "karachi" });

// Filter: WHERE name = 'ali' AND age = 21
db.students.find({ name: "ali", age: 21 });

// Filter: WHERE city = 'karachi' OR city = 'lahore'
db.students.find({
  $or: [{ city: "karachi" }, { city: "lahore" }]
});

// AND + OR combined: WHERE age > 20 AND (city = 'karachi' OR city = 'lahore')
db.students.find({
  age: { $gt: 20 },
  $or: [{ city: "karachi" }, { city: "lahore" }]
});

// Filter: WHERE id IN (101, 102, 103)
db.students.find({ _id: { $in: [101, 102, 103] } });

// Filter: WHERE id NOT IN (101, 102)
db.students.find({ _id: { $nin: [101, 102] } });

// Filter: WHERE city <> 'karachi'
db.students.find({ city: { $ne: "karachi" } });

// Filter: WHERE age > 20
db.students.find({ age: { $gt: 20 } });

// Logical NOT: WHERE age is NOT greater than 20
db.students.find({ age: { $not: { $gt: 20 } } });

// Filter: WHERE age >= 20 AND age <= 30
db.students.find({ age: { $gte: 20, $lte: 30 } });

// WHERE age >= 20 OR age <= 10
db.students.find({
  $or: [
    { age: { $gte: 20 } },
    { age: { $lte: 10 } }
  ]
});


// SEARCH without $regex operator
db.students.find({ name: /ali/i }); // case-insensitive contains "ali"
db.students.find({ name: /^a/ });   // starts with "a"
db.students.find({ name: /i$/ });   // ends with "i"
db.students.find({ name: { $not: /^a/i } });                    // name does NOT start with "a"


// SEARCH using $regex operator
db.students.find({ name: { $regex: "ali", $options: "i" } });   // case‑insensitive contains "ali"
db.students.find({ name: { $regex: "^ali", $options: "i" } });  // case‑insensitive starts with "ali" 
db.students.find({ name: { $regex: "ali$", $options: "i" } });  // case‑insensitive ends with "ali"


// TEXT SEARCH (requires a text index on the fields you want to search)
db.students.createIndex({ name: "text", city: "text" });

// searches all documents' fields
db.students.find({ $text: { $search: "ali" } });           // contains "ali" in any indexed field
db.students.find({ $text: { $search: '"ali" "karachi"' } }); // contains both "ali" AND "karachi"
db.students.find({ $text: { $search: "ali karachi" } });     // contains either "ali" OR "karachi"
db.students.find({ $text: { $search: "ali -karachi" } });    // contains "ali" but EXCLUDES "karachi"


// PROJECTION: SELECT name, city FROM students (show only name & city, hide _id)
db.students.find({}, { name: 1, city: 1, _id: 0 });

// PROJECTION with filter: SELECT name, age FROM students WHERE city = 'karachi'
db.students.find({ city: "karachi" }, { name: 1, age: 1, _id: 0 });

// Sort: ORDER BY name ASC (1 = ascending, -1 = descending)
db.students.find().sort({ name: 1 });

// Sort by multiple fields: ORDER BY city ASC, name DESC
db.students.find().sort({ city: 1, name: -1 });

// Limit: LIMIT 5
db.students.find().limit(5);

// Skip + Limit (pagination): skip first 5, then get next 5
db.students.find().skip(5).limit(5);

// Count: COUNT(*)
db.students.countDocuments();

// Count with filter: COUNT(*) WHERE city = 'karachi'
db.students.countDocuments({ city: "karachi" });

// DISTINCT: SELECT DISTINCT city FROM students
db.students.distinct("city");


// ------------------------------------------------------------------------
// UPDATE COMMANDS
// ------------------------------------------------------------------------

// Updates the first matching document.
db.students.updateOne(
  { _id: 101 },
  { $set: { city: "Lahore" } }
);

db.students.updateOne(
  { name: "ali" },
  { $set: { city: "islamabad", age: 28 } }
);

// findOneAndUpdate: Updates one doc and returns the document.
// By default it returns the OLD document. Use { returnDocument: "after" } for the NEW one.
db.students.findOneAndUpdate(
  { name: "ali" },
  { $set: { age: 30 } },
  { "returnNewDocument": true }
);

// Update ALL matching documents (updateMany).
db.students.updateMany(
  { city: "karachi" },
  { $set: { city: "Karachi" } }
);

// Increment a numeric field: age = age + 2
db.students.updateOne(
  { name: "ali" },
  { $inc: { age: 2 } }
);

// Add a new field to all documents.
db.students.updateMany(
  {},
  { $set: { status: "active" } }
);

// Rename a field in all documents.
db.students.updateMany(
  {},
  { $rename: { "city": "location" } }
);


// ------------------------------------------------------------------------
// DELETE COMMANDS
// ------------------------------------------------------------------------

// Deletes the first student who is named "ali" AND lives in "Karachi"
db.students.deleteOne({ 
    name: "ali", 
    city: "karachi" 
});

// findOneAndDelete: Deletes the first match and returns the deleted document.
db.students.findOneAndDelete({ name: "sara" });

// Deletes ALL documents where city is "lahore".
db.students.deleteMany({ city: "lahore" });

// Deletes ALL documents in the collection (empty filter = match all).
db.students.deleteMany({});


// ------------------------------------------------------------------------
// DROP COMMANDS
// ------------------------------------------------------------------------

// Deletes just the "students" collection.
db.students.drop();

// Deletes the entire current database.
db.dropDatabase();


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

// Min and Max age per city.
db.students.aggregate([
  { $group: { _id: "$city", minAge: { $min: "$age" }, maxAge: { $max: "$age" } } }
]);

// Sum of ages per city.
db.students.aggregate([
  { $group: { _id: "$city", totalAge: { $sum: "$age" } } }
]);

// Filter THEN group: WHERE age > 20 GROUP BY city
// $match is like WHERE, $group is like GROUP BY
db.students.aggregate([
  { $match: { age: { $gt: 20 } } },
  { $group: { _id: "$city", count: { $sum: 1 } } }
]);

// Filter THEN group: WHERE age > 20 AND age <= 30 GROUP BY city
db.students.aggregate([
    { $match: { age: { $gt: 20, $lte: 30 } } },
    { $group: { _id: "$city", count: { $sum: 1 } } }
]);

// Filter THEN group: WHERE age > 20 OR age <= 10 GROUP BY city
db.students.aggregate([
  { $match: { $or: [{ age: { $gt: 20 } }, { age: { $lte: 10 } }] } },
  { $group: { _id: "$city", count: { $sum: 1 } } }
]);

// Group THEN filter (HAVING): GROUP BY city HAVING count > 1
db.students.aggregate([
  { $group: { _id: "$city", count: { $sum: 1 } } },
  { $match: { count: { $gt: 1 } } }
]);

// Sort aggregation results: GROUP BY city ORDER BY count DESC
db.students.aggregate([
  { $group: { _id: "$city", count: { $sum: 1 } } },
  { $sort: { count: -1 } }
]);

// Limit aggregation results to top 3
db.students.aggregate([
  { $group: { _id: "$city", count: { $sum: 1 } } },
  { $sort: { count: -1 } },
  { $limit: 3 }
]);

// SELECT city, COUNT(*) as total FROM students 
// WHERE age > 18 
// GROUP BY city 
// HAVING total > 2 
// ORDER BY total DESC
// LIMIT 5;
db.students.aggregate([
  { $match: { age: { $gt: 18 } } },                 
  { $group: { _id: "$city", total: { $sum: 1 } } },  
  { $match: { total: { $gt: 2 } } },                
  { $sort: { total: -1 } },
  { $limit: 5 }                         
]);