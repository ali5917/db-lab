// MongoDB Lab Practice – UniversityDB

// Database Setup
use UniversityDB;
db.createCollection("students");

// Insert initial data
db.students.insertMany([
  { _id: 1, name: "Ali", age: 21, city: "Karachi", department: "CS", grades: { math: 88, science: 75 } },
  { _id: 2, name: "Sara", age: 22, city: "Lahore", department: "EE", grades: { math: 90, science: 85 } },
  { _id: 3, name: "Usman", age: 20, city: "Karachi", department: "CS", grades: { math: 60, science: 70 } },
  { _id: 4, name: "Ayesha", age: 23, city: "Islamabad", department: "BBA", grades: { math: 95, science: 92 } },
  { _id: 5, name: "Bilal", age: 21, city: "Karachi", department: "CS", grades: { math: 55, science: 80 } }
]);

// Q1: Retrieve all students
db.students.find();

// Q2: Retrieve students from Karachi
db.students.find({
    city:'Karachi'
});

// Q3: Retrieve students where name = "Ali" OR age = 21
db.students.find({
    $or: [{name: 'Ali'}, {age:21}]    
});

// Q4: Show only name and grades of CS students from Karachi (exclude city, dept, and _id)
db.students.find({
    city: 'Karachi',
    department: 'CS'           
}, {name: 1, grades: 1, _id: 0});

// Q5: Return only specific nested fields (grades.math, grades.science) for all students
db.students.find({}, {
    name: 1,
    "grades.math": 1, 
    "grades.science": 1
})

// Q6: Students where: math < 80 OR age > 22
db.students.find({
    $or: [
        {"grades.math": { $lt: 80 } },
        {age: { $gt: 22}}
    ]        
});

// Q7: Students where: city = Lahore OR (math >= 65 AND science >= 85)
db.students.find({
    $or: [
        {city: 'Lahore'},
        {"grades.math": {$gte: 65}, "grades.science": {$gte: 85}}        
    ]    
});

// Q13: Find all students in the 'CS' department who have a math grade greater than 80
db.students.find({
    department: 'CS',
    "grades.math": {$gt: 80}        
});

// Q14: Names starting with "A"
db.students.find({
    name: {$regex: '^A'}    
});

// Q15: Names ending with "a"
db.students.find({
    name: {$regex: 'a$'}    
});

// Q16: Names containing "i"
db.students.find({
    name: {$regex: 'i'}    
});

// Q17: Case-insensitive search for "a"
db.students.find({
    name: {$regex: 'a', $options: 'i'}    
});

// Q18: Sort by math ascending
db.students.find().sort({"grades.math": 1});

// Q20: Get top 2 students by math score
db.students.find().sort({"grades.math": -1}).limit(2);

// Q21: Sort by city (ASC) then math score (DESC)
db.students.find().sort({
    city: 1,
    "grades.math": -1
});

// Q22: Count total students
db.students.countDocuments();

// Q23: Count students from Karachi
db.students.countDocuments({
    city: "Karachi"
});

// Q24: Increase science by 10 where: department = CS AND math < 70 
db.students.updateMany(
    {department: 'CS', "grades.math": {$lt: 70}},
    {$inc: {"grades.science": 10}}
);

// Q25: Increase math by 5 where: science < 80 AND age > 22 
db.students.updateMany(
    {"grades.science": {$lt: 80}, age: {$gt: 22}},
    {$inc: {"grades.math": 5}}
);

// Q26: Update city of student with _id = 1 to Rawalpindi 
db.students.updateOne(
    {_id: 1},
    {$set: {city: "Rawalpindi"}}
);

// Q28: Delete student: name = "Bilal" AND department = CS 
db.students.deleteOne({
    name: 'Bilal',
    department: 'CS'
})

// Q29: Delete students where: age > 23 
db.students.deleteMany({
    age: {$gt: 23}
})

// Q30: Delete students where: city = Lahore OR department = EE 
db.students.deleteMany({
    $or: [
        {city: 'Lahore'},
        {department: 'EE'}
    ]
})

// Q31: Count students per department
db.students.aggregate([
    {$group: {_id: "$department", count: {$sum: 1}}}
]);

// Q32: Average math score per city
db.students.aggregate([
    {$group: {_id: '$city', avgScore: {$avg: "$grades.math"}}}
]);

// Q33: Only include cities where avg math > 75 
db.students.aggregate([
    {$group: {_id: '$city', avgMath: {$avg: "$grades.math"}}},
    {$match: {avgMath: {$gt: 75}}}
]);

// Q34: Sort cities by average math score descending
db.students.aggregate([
    {$group: {_id: '$city', avgMath: {$avg: "$grades.math"}}},
    {$sort: {avgMath: -1}}
]);

// Drop Students collection
db.students.drop();

// Drop UniversityDB database
db.dropDatabase();