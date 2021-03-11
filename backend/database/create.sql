-- For SQLite DBMS.

-- Turn on foreign key constraint enforcement.
PRAGMA foreign_keys = ON;

CREATE TABLE delivery_users(
	user_id INTEGER PRIMARY KEY, -- alias for the automatic ROWID column
	username VARCHAR,
	hash VARCHAR
);

CREATE TABLE categories(
	category_id INTEGER PRIMARY KEY,
	name VARCHAR
);

CREATE TABLE items(
	item_id INTEGER PRIMARY KEY,
	name VARCHAR NOT NULL,
	image_name VARCHAR,
	category_id INT,
	
	FOREIGN KEY(category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

CREATE TABLE orders(
	order_id INT PRIMARY KEY,
	first_name VARCHAR,
	last_name VARCHAR,
	street VARCHAR,
	street_number VARCHAR,
	city VARCHAR,
	postal_code VARCHAR
);

CREATE TABLE order_items(
	order_id INT,
	item_id INT,
	quantity INT,
	
	PRIMARY KEY(order_id, item_id),
	FOREIGN KEY(order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
	FOREIGN KEY(item_id) REFERENCES items(item_id) ON DELETE SET NULL
);