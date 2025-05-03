
# Neo4j Property Graph with Constraints and Validation

This repository contains two key Cypher script files designed for demonstrating and testing PG-Schema and PG-Keys concepts in Neo4j.

## 📁 Files

### `neo4j_graph.cypher`
This file initializes a social network graph in Neo4j by defining nodes and relationships such as `Person`, `Post`, `Comment`, `Message`, `Group`, and `PhotoAlbum`. It includes:

- **Nodes** with detailed properties (e.g., name, email, age)
- **Relationships** like `CREATES`, `SENT`, `HAS_COMMENT`, and `MEMBER_OF` with property annotations
- **Cypher constraints** for ensuring properties such as `email` are unique and not null
- **A singleton constraint**: implemented via Cypher logic to ensure that each person has at most one `LIVES_IN` relationship (only one location at a time)

### `neo4j_constraint_tests.cypher`
This script contains a variety of test cases to verify the effectiveness of the constraints and validate schema rules. It tests:

- 🔒 **Uniqueness of Emails**: Verifies whether two users can share the same email address
- 📨 **Friend Request ID Uniqueness**: Ensures no duplicate `requestID` values
- 👥 **Group Membership**: Prevents duplicate memberships for the same user and group
- 📝 **Post ID Uniqueness**: Prevents posts with the same ID
- 🏠 **Singleton Check for LIVES_IN**: Verifies that no user can have multiple residences
- 🚫 **Schema Violations**: Includes failing examples like creating a post without content or a group without description
- 🔗 **Graph Connectivity**: Checks whether users like Alice are correctly connected to other nodes

Each test block returns a message confirming success or indicating an error, allowing for simple inspection and validation. Sometimes, checks are included to skip creation queries if certain conditions are already met, in order to avoid duplicates.

## ✅ Usage
1. Make sure you have Neo4j Desktop running.
2. Open Neo4j Browser and connect to your database.
3. Run `neo4j_graph.cypher` first to set up the schema, nodes, relationships, and constraints.
4. Execute the following query to vizualize your graph: match(n) return n
2. Then execute `neo4j_constraint_tests.cypher` to verify that all constraints behave as expected.

## 📌 Notes

- Requires Neo4j 5.x or newer with support for Cypher constraints.
- The `MERGE` and `ON CREATE SET` statements ensure idempotent setup.
- This example mimics formal PG-Schema and PG-Key enforcement using Neo4j-native mechanisms.

## 🔗 Reference

Inspired by PG-Schema and PG-Keys:  
Angles et al. (2023). *PG-Schema: Schemas for Property Graphs*.  
Bonifati et al. (2023). *PG-Keys: Keys for Property Graphs*.
