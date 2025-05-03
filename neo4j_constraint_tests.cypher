// Test der PG-Keys

// Doppelte E-Mail-Adressen überprüfen
MATCH (:Person {email: 'alice@example.com'})
RETURN 'Error: Duplicate email detected!' AS message

UNION

// Falls die E-Mail noch nicht existiert, neuen Benutzer erstellen
MATCH (n) // Dummy-Match, um UNION zu ermöglichen
WHERE NOT EXISTS { MATCH (:Person {email: 'alice@example.com'}) }
CREATE (pNew:Person {username: 'Eve', email: 'alice@example.com', age: 28, profession: 'Scientist'})
RETURN 'New user created successfully' AS message;

//Doppelte Freundschaftsanfrage überprüfen
MATCH (:Person)-[r:SENT_REQUEST {requestID: '5002'}]->(:Person)
RETURN 'Error: Duplicate requestID detected!' AS message
UNION
MATCH (bob:Person {username: 'Bob'}), (alice:Person {username: 'Alice'})
WHERE NOT EXISTS { MATCH (:Person)-[r:SENT_REQUEST {requestID: '5002'}]->(:Person) }
CREATE (bob)-[:SENT_REQUEST {requestID: '5002', status: 'pending'}]->(alice)
RETURN 'Friend request created' AS message;

//Doppelte Mitgliedschaften überprüfen
MATCH (:Person)-[r:MEMBER_OF {membershipID: 'neo4j001'}]->(:Group)
RETURN 'Error: Duplicate membership detected!' AS message
UNION
MATCH (alice:Person {username: 'Alice'}), (group1:Group {name: 'Neo4j Enthusiasts'})
WHERE NOT EXISTS { MATCH (:Person)-[r:MEMBER_OF {membershipID: 'neo4j001'}]->(:Group) }
CREATE (alice)-[:MEMBER_OF {membershipID: 'neo4j001', since: '2024-09-20', grouprole: 'member'}]->(group1)
RETURN 'Membership created' AS message;

// Zwei Posts mit gleicher ID verhindern
// Prüfen, ob ein Post mit postID 'post-2' bereits existiert
MATCH (p:Post {postID: 'post-2'})
RETURN 'Error: Duplicate postID detected! A post with this ID already exists.' AS message

UNION

// Falls die ID nicht existiert, darf Bob den Post erstellen
MATCH (bob:Person {username: 'Bob'})
WHERE NOT EXISTS { MATCH (p:Post {postID: 'post-2'}) }
CREATE (post3:Post {postID: 'post-2', content: 'Trying duplicate post', category: 'Tech', timestamp: '2024-11-01T10:07:49.531Z'})
CREATE (bob)-[:CREATES]->(post3)
RETURN 'Post created successfully' AS message;

// Singleton-Vorbereitung: Person und zwei Orte
MERGE (bob:Person {username: 'Bob'})
MERGE (paris:Location {name: 'Paris'})
MERGE (berlin:Location {name: 'Berlin'})
MERGE (bob)-[:LIVES_IN]->(paris)
MERGE (bob)-[:LIVES_IN]->(berlin)
WITH bob

// Singleton-Überprüfung: Gibt eine Fehlermeldung zurück, wenn zwei unterschiedliche Orte verknüpft sind
MATCH (bob)-[:LIVES_IN]->(l1:Location),
      (bob)-[:LIVES_IN]->(l2:Location)
WHERE l1 <> l2
RETURN 'Error: Bob has multiple LIVES_IN relationships!' AS message;


// Test der PG-Schemas

//Versuch einen Post zu erstellen ohne 'content' property
CREATE (p:Post {timestamp: datetime()});
// Neo.ClientError.Schema.ConstraintValidationFailed Node(21) with label `Post` must have the property `content`

//Beweis, dass Alice und ihre Beziehungen richtig initialisiert wurden
MATCH (alice:Person {username: 'Alice'})
WHERE NOT EXISTS { MATCH (alice)--() }
RETURN 'Error: Alice is an isolated node!' AS message, alice, NULL AS related

UNION

MATCH (alice:Person {username: 'Alice'})--(related)
RETURN 'Alice is correctly linked in the graph. Connections exist.' AS message, alice, related;

//Gruppe ohne 'description' erstellen
CREATE (g:Group {name: 'Incomplete Group'});
// Neo.ClientError.Schema.ConstraintValidationFailed Node(22) with label `Group` must have the property `description`