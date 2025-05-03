// Constraints für Knoten-Eigenschaften erstellen
CREATE CONSTRAINT FOR (p:Person) REQUIRE (p.email) IS UNIQUE;
CREATE CONSTRAINT FOR (p:Person) REQUIRE (p.username) IS UNIQUE;
CREATE CONSTRAINT FOR (p:Person) REQUIRE (p.username) IS NOT NULL;
CREATE CONSTRAINT FOR (p:Person) REQUIRE (p.email) IS NOT NULL;
CREATE CONSTRAINT FOR (p:Person) REQUIRE (p.age) IS NOT NULL;
CREATE CONSTRAINT FOR (p:Person) REQUIRE (p.profession) IS NOT NULL;

CREATE CONSTRAINT FOR (m:Message) REQUIRE (m.content) IS NOT NULL;
CREATE CONSTRAINT FOR (m:Message) REQUIRE (m.timestamp) IS NOT NULL;

CREATE CONSTRAINT FOR (c:Comment) REQUIRE (c.content) IS NOT NULL;
CREATE CONSTRAINT FOR (c:Comment) REQUIRE (c.timestamp) IS NOT NULL;

CREATE CONSTRAINT FOR (o:Post) REQUIRE (o.content) IS NOT NULL;
CREATE CONSTRAINT FOR (p:Post) REQUIRE (p.postID) IS UNIQUE;
CREATE CONSTRAINT FOR (o:Post) REQUIRE (o.timestamp) IS NOT NULL;

CREATE CONSTRAINT FOR (g:Group) REQUIRE (g.name) IS NOT NULL;
CREATE CONSTRAINT FOR (g:Group) REQUIRE (g.description) IS NOT NULL;
CREATE CONSTRAINT FOR (g:Group) REQUIRE (g.membershipID) IS UNIQUE;

CREATE CONSTRAINT FOR (a:PhotoAlbum) REQUIRE (a.name) IS NOT NULL;
CREATE CONSTRAINT FOR (a:PhotoAlbum) REQUIRE (a.timestamp) IS NOT NULL;
CREATE CONSTRAINT FOR (p:Post) REQUIRE (p.timestamp) IS UNIQUE;
CREATE CONSTRAINT FOR ()-[r:SENT_REQUEST]-() REQUIRE r.requestID IS UNIQUE;

// Personen anlegen
CREATE (alice:Person {id: '001', username: 'Alice', email: 'alice@example.com', age: 30, profession: 'Engineer'}) 
CREATE (bob:Person {id: '002', username: 'Bob', email: 'bob@example.com', age: 25, profession: 'Data Scientist'}) 
CREATE (carol:Person {id: '003', username: 'Carol', email: 'carol@example.com', age: 27, profession: 'Designer'});

CREATE (message1:Message {content: 'Hey, how are you?', priority: 'high', timestamp: '2024-10-18T10:07:49.531Z'}) 
CREATE (post1:Post {postID: 'post-1', content: 'Hello World', category: 'Blog', likes: 10, status: 'published', timestamp: '2024-10-31T10:07:49.531Z'}) 
CREATE (post2:Post {postID: 'post-2', content: 'My first post', category: 'News', likes: 5, status: 'archived', timestamp: '2024-10-15T10:07:49.531Z'}) 
CREATE (comment1:Comment {content: 'Nice post!', timestamp: '2024-10-20T10:07:49.531Z', upvotes: 5}) 
CREATE (comment2:Comment {content: 'Thanks for sharing', timestamp: '2024-10-20T10:07:49.531Z', upvotes: 3});

// Gruppen anlegen
CREATE (group1:Group {name: 'Neo4j Enthusiasts', description: 'A group for Neo4j fans', members: 100, privacyLevel: 'public'});

// Fotoalbum anlegen
CREATE (album1:PhotoAlbum {name: 'Vacation', popularity: 90, timestamp: '2024-10-31T10:07:49.531Z'});

// ALLE Nodes miteinander verknüpfen:
MATCH (alice:Person {username: 'Alice'})
MATCH (bob:Person {username: 'Bob'})
MATCH (carol:Person {username: 'Carol'})
MATCH (group1:Group {name: 'Neo4j Enthusiasts'})
MATCH (message1:Message {content: 'Hey, how are you?'})
MATCH (post1:Post {content: 'Hello World'})
MATCH (post2:Post {content: 'My first post'})
MATCH (comment1:Comment {content: 'Nice post!'})
MATCH (comment2:Comment {content: 'Thanks for sharing'})
MATCH (album1:PhotoAlbum {name: 'Vacation'})

// Mitglieder der Gruppe mit einzigartiger membershipID
CREATE (alice)-[:MEMBER_OF {membershipID: 'neo4j001', since: '2024-09-20', grouprole: 'admin'}]->(group1)
CREATE (bob)-[:MEMBER_OF {membershipID: 'neo4j002', since: '2024-09-20', grouprole: 'member'}]->(group1)
CREATE (carol)-[:MEMBER_OF {membershipID: 'neo4j003', since: '2024-09-20', grouprole: 'member'}]->(group1)

// Fotoalbum-Post Verbindung
CREATE (album1)-[:CONTAINS {addedDate: '2024-10-31', postType: 'Blog'}]->(post1)

// Nachrichtenverlauf
CREATE (alice)-[:SENT {sentAt: '2024-10-18T10:07:49.531Z', poststatus: 'delivered'}]->(message1)
CREATE (message1)-[:RECEIVED_BY {receivedAt: '2024-10-18T10:07:49.531Z', isRead: false}]->(bob)

// Posts und Kommentare
CREATE (alice)-[:CREATES]->(post1)
CREATE (bob)-[:CREATES]->(post2)
CREATE (post1)-[:HAS_COMMENT]->(comment1)
CREATE (post2)-[:HAS_COMMENT]->(comment2)
CREATE (carol)-[:CREATES]->(comment1)
CREATE (alice)-[:CREATES]->(comment2)
CREATE (group1)-[:HAS_POST {postStatus: 'approved'}]->(post1)
CREATE (group1)-[:HAS_POST {postStatus: 'pending'}]->(post2)

// Freundschaftsanfragen
CREATE (bob)-[:SENT_REQUEST {requestID: '5002', status: 'accepted'}]->(alice)
CREATE (alice)-[:SENT_REQUEST {requestID: '5001', status: 'pending'}]->(carol)

// Social Media Beziehungen
CREATE (alice)-[:FOLLOWS {since: '2023-10-20'}]->(bob)

// Singleton Constraint: Eine Person kann nur an einem Ort leben
MERGE (loc1:Location {name: 'Berlin'})
MERGE (alice)-[:LIVES_IN]->(loc1)
WITH alice, loc1
MATCH (p:Person)-[:LIVES_IN]->(l1:Location),
      (p)-[:LIVES_IN]->(l2:Location)
WHERE l1 <> l2
RETURN 'Error: Person cannot have multiple LIVES_IN relationships!' AS message;

MATCH (alice:Person {username: 'Alice'})
OPTIONAL MATCH (alice)-[rel:LIVES_IN]->(:Location)
WITH alice, rel
WHERE rel IS NOT NULL  // Falls bereits eine Beziehung existiert
RETURN 'Error: Alice already lives in a city!' AS message;

// Bob lebt in Paris
MATCH (bob:Person {username: 'Bob'})
MERGE (paris:Location {name: 'Paris'})
MERGE (bob)-[:LIVES_IN]->(paris);
MERGE (loc2:Location {name: 'Paris'})
MERGE (bob)-[:LIVES_IN]->(loc2)
WITH bob, loc2
MATCH (p:Person)-[:LIVES_IN]->(l1:Location),
      (p)-[:LIVES_IN]->(l2:Location)
WHERE l1 <> l2
RETURN 'Error: Person cannot have multiple LIVES_IN relationships!' AS message;

MATCH (bob:Person {username: 'Bob'})
OPTIONAL MATCH (bob)-[rel:LIVES_IN]->(:Location)
WITH bob, rel
WHERE rel IS NOT NULL  // Falls bereits eine Beziehung existiert
RETURN 'Error: Bob already lives in a city!' AS message;

// Carol lebt in London
MATCH (carol:Person {username: 'Carol'})
MERGE (london:Location {name: 'London'})
MERGE (carol)-[:LIVES_IN]->(london);
MERGE (loc3:Location {name: 'London'})
MERGE (carol)-[:LIVES_IN]->(loc3)
WITH carol, loc3
MATCH (p:Person)-[:LIVES_IN]->(l1:Location),
      (p)-[:LIVES_IN]->(l2:Location)
WHERE l1 <> l2
RETURN 'Error: Person cannot have multiple LIVES_IN relationships!' AS message;

MATCH (carol:Person {username: 'Carol'})
OPTIONAL MATCH (carol)-[rel:LIVES_IN]->(:Location)
WITH carol, rel
WHERE rel IS NOT NULL  // Falls bereits eine Beziehung existiert
RETURN 'Error: Carol already lives in a city!' AS message;