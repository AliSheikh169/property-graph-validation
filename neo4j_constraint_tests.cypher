// Testing PG-Keys

// Check for duplicate email addresses
MATCH (:Person {email: 'alice@example.com'})
RETURN 'Error: Duplicate email detected!' AS message

UNION

// If the email does not yet exist, create a new user
MATCH (n) // Dummy match to enable UNION
WHERE NOT EXISTS { MATCH (:Person {email: 'alice@example.com'}) }
CREATE (pNew:Person {username: 'Eve', email: 'alice@example.com', age: 28, profession: 'Scientist'})
RETURN 'New user created successfully' AS message;

// Check for duplicate friend request
MATCH (:Person)-[r:SENT_REQUEST {requestID: '5002'}]->(:Person)
RETURN 'Error: Duplicate requestID detected!' AS message
UNION
MATCH (bob:Person {username: 'Bob'}), (alice:Person {username: 'Alice'})
WHERE NOT EXISTS { MATCH (:Person)-[r:SENT_REQUEST {requestID: '5002'}]->(:Person) }
CREATE (bob)-[:SENT_REQUEST {requestID: '5002', status: 'pending'}]->(alice)
RETURN 'Friend request created' AS message;

// Check for duplicate group memberships
MATCH (:Person)-[r:MEMBER_OF {membershipID: 'neo4j001'}]->(:Group)
RETURN 'Error: Duplicate membership detected!' AS message
UNION
MATCH (alice:Person {username: 'Alice'}), (group1:Group {name: 'Neo4j Enthusiasts'})
WHERE NOT EXISTS { MATCH (:Person)-[r:MEMBER_OF {membershipID: 'neo4j001'}]->(:Group) }
CREATE (alice)-[:MEMBER_OF {membershipID: 'neo4j001', since: '2024-09-20', grouprole: 'member'}]->(group1)
RETURN 'Membership created' AS message;

// Prevent two posts with the same ID
// Check if a post with postID 'post-2' already exists
MATCH (p:Post {postID: 'post-2'})
RETURN 'Error: Duplicate postID detected! A post with this ID already exists.' AS message

UNION

// If the ID does not exist, allow Bob to create the post
MATCH (bob:Person {username: 'Bob'})
WHERE NOT EXISTS { MATCH (p:Post {postID: 'post-2'}) }
CREATE (post3:Post {postID: 'post-2', content: 'Trying duplicate post', category: 'Tech', timestamp: '2024-11-01T10:07:49.531Z'})
CREATE (bob)-[:CREATES]->(post3)
RETURN 'Post created successfully' AS message;

// Singleton setup: Person and two locations
MERGE (bob:Person {username: 'Bob'})
MERGE (paris:Location {name: 'Paris'})
MERGE (berlin:Location {name: 'Berlin'})
MERGE (bob)-[:LIVES_IN]->(paris)
MERGE (bob)-[:LIVES_IN]->(berlin)
WITH bob

// Singleton check: Returns error message if two different locations are linked
MATCH (bob)-[:LIVES_IN]->(l1:Location),
      (bob)-[:LIVES_IN]->(l2:Location)
WHERE l1 <> l2
RETURN 'Error: Bob has multiple LIVES_IN relationships!' AS message;


// Testing PG-Schemas

// Attempt to create a post without the 'content' property
CREATE (p:Post {timestamp: datetime()});
// Neo.ClientError.Schema.ConstraintValidationFailed Node(21) with label `Post` must have the property `content`

// Check that Alice and her relationships are correctly initialized
MATCH (alice:Person {username: 'Alice'})
WHERE NOT EXISTS { MATCH (alice)--() }
RETURN 'Error: Alice is an isolated node!' AS message, alice, NULL AS related

UNION

MATCH (alice:Person {username: 'Alice'})--(related)
RETURN 'Alice is correctly linked in the graph. Connections exist.' AS message, alice, related;

// Attempt to create a group without 'description'
CREATE (g:Group {name: 'Incomplete Group'});
// Neo.ClientError.Schema.ConstraintValidationFailed Node(22) with label `Group` must have the property `description`
