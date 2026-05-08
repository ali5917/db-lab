-- PROBLEM: Smart City River Pollution and Water Quality Control System

-- Collection: water_quality
-- Attributes:
--   - sample_id
--   - zone
--   - pollution_level
--   - contamination_type
--   - status
--   - officer_id
--   - officer_name
--   - designation

-- TASK LIST:
-- 1. Setup: Check available databases, switch to a dedicated working database.
show dbs;
use myDb;

-- 2. Collection: Create a collection named 'water_quality' to store monitoring data.
db.createCollection('water_quality');

-- 3. Insertion: 
--    - Insert an environmental officer record.
--    - Insert multiple water sample readings from different zones.
--    - Display all data to verify insertion.

db.water_quality.insertMany([
    {
        sample_id: 101,
        zone: "North River Zone",
        pollution_level: 85,
        contamination_type: "Chemical",
        status: "Untreated",
        officer_id: "OFF_01",
        officer_name: "John Doe",
        designation: "Environmental Inspector"
    },
    {
        sample_id: 102,
        zone: "South Zone",
        pollution_level: 40,
        contamination_type: "Biological",
        status: "Untreated",
        officer_id: "OFF_01",
        officer_name: "John Doe",
        designation: "Environmental Inspector"
    },
    {
        sample_id: 103,
        zone: "North River Zone",
        pollution_level: 95,
        contamination_type: "Industrial",
        status: "Untreated",
        officer_id: "OFF_01",
        officer_name: "John Doe",
        designation: "Environmental Inspector"
    },
    {
        sample_id: 104,
        zone: "East Zone",
        pollution_level: 65,
        contamination_type: "Organic",
        status: "Untreated",
        officer_id: "OFF_01",
        officer_name: "John Doe",
        designation: "Environmental Inspector"
    }
]);

db.water_quality.find();

-- 4. Retrieval & Sorting: 
--    - Find records from 'North River Zone'.
--    - Sort by 'pollution_level' in descending order.

db.water_quality.find({
    zone: 'North River Zone'
}).sort({pollution_level: -1});

-- 5. Comparative Analysis: Filter out records that do NOT belong to the 'South Zone'.

db.water_quality.find({
    zone: {$ne: 'South Zone'}
});

-- 6. Update & Verification: 
--    - Update a specific polluted sample to status 'treated'.
--    - Reassign it to 'Central Treatment Unit'.
--    - Recheck the record to ensure accuracy.

db.water_quality.updateOne(
    {sample_id: 104},
    {$set: {status: 'treated', zone: 'Central Treatment Unit'}},
);

-- 7. Reporting: Display only selected fields.


-- 8. Analytics: Group by zone and calculate average pollution level.
db.water_quality.aggregate([
    { $group: { _id: "$zone", avgPollution: { $avg: "$pollution_level" } } }
]);