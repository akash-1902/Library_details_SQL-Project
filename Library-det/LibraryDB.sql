-- Create the database
CREATE DATABASE LibraryDB;

-- Select the database to use
USE LibraryDB;

-- Create the Authors table
-- This table stores information about authors.
CREATE TABLE Authors (
    AuthorID INT PRIMARY KEY,  -- Unique identifier for each author
    Name VARCHAR(100)          -- Name of the author
);

-- Insert records into the Authors table
-- Adding sample authors to the Authors table.
INSERT INTO Authors (AuthorID, Name) VALUES
(1, 'J.K. Rowling'),
(2, 'George R.R. Martin'),
(3, 'J.R.R. Tolkien'),
(4, 'Agatha Christie'),
(5, 'Stephen King'),
(6, 'Isaac Asimov'),
(7, 'Arthur Conan Doyle'),
(8, 'Mark Twain');

-- Create the Books table
-- This table stores information about books.
CREATE TABLE Books (
    BookID INT PRIMARY KEY,   -- Unique identifier for each book
    Title VARCHAR(100),       -- Title of the book
    AuthorID INT,             -- ID of the author from the Authors table
    FOREIGN KEY (AuthorID) REFERENCES Authors(AuthorID)  -- Foreign key constraint to link to Authors table
);

-- Insert records into the Books table
-- Adding sample books to the Books table.
INSERT INTO Books (BookID, Title, AuthorID) VALUES
(1, 'Harry Potter and the Philosopher\'s Stone', 1),
(2, 'A Game of Thrones', 2),
(3, 'The Hobbit', 3),
(4, 'Murder on the Orient Express', 4),
(5, 'The Shining', 5),
(6, 'Foundation', 6),
(7, 'Sherlock Holmes: The Complete Novels and Stories', 7),
(8, 'Adventures of Huckleberry Finn', 8);

-- Create the Members table
-- This table stores information about library members.
CREATE TABLE Members (
    MemberID INT PRIMARY KEY, -- Unique identifier for each member
    Name VARCHAR(100),        -- Name of the member
    JoinDate DATE             -- Date when the member joined the library
);

-- Insert records into the Members table
-- Adding sample members to the Members table.
INSERT INTO Members (MemberID, Name, JoinDate) VALUES
(1, 'Alice Johnson', '2023-01-15'),
(2, 'Bob Smith', '2023-02-20'),
(3, 'Charlie Brown', '2023-03-05'),
(4, 'Diana Prince', '2023-04-10'),
(5, 'Edward Cullen', '2023-05-25'),
(6, 'Fiona Shrek', '2023-06-30'),
(7, 'George Weasley', '2023-07-15'),
(8, 'Hannah Montana', '2023-08-20');

-- Create the Borrowings table
-- This table records the borrowing activities of members.
CREATE TABLE Borrowings (
    BorrowingID INT PRIMARY KEY, -- Unique identifier for each borrowing record
    BookID INT,                  -- ID of the borrowed book from the Books table
    MemberID INT,                -- ID of the member from the Members table
    BorrowDate DATE,             -- Date when the book was borrowed
    ReturnDate DATE,             -- Date when the book was returned (can be NULL if not yet returned)
    FOREIGN KEY (BookID) REFERENCES Books(BookID),    -- Foreign key constraint to link to Books table
    FOREIGN KEY (MemberID) REFERENCES Members(MemberID) -- Foreign key constraint to link to Members table
);

-- Insert records into the Borrowings table
-- Adding sample borrowing records to the Borrowings table.
INSERT INTO Borrowings (BorrowingID, BookID, MemberID, BorrowDate, ReturnDate) VALUES
(1, 1, 1, '2024-01-01', NULL),
(2, 2, 2, '2024-01-05', '2024-01-15'),
(3, 3, 3, '2024-01-10', NULL),
(4, 4, 4, '2024-01-15', '2024-01-25'),
(5, 5, 5, '2024-01-20', NULL),
(6, 6, 6, '2024-01-25', '2024-02-04'),
(7, 7, 7, '2024-02-01', NULL),
(8, 8, 8, '2024-02-05', '2024-02-15');

-- Stored Procedure to borrow a book
-- This procedure allows a member to borrow a book by inserting a new record into the Borrowings table.
DELIMITER //
CREATE PROCEDURE BorrowBook(IN bookID INT, IN memberID INT, IN borrowDate DATE)
BEGIN
    INSERT INTO Borrowings (BookID, MemberID, BorrowDate) VALUES (bookID, memberID, borrowDate);
END //
DELIMITER ;

-- List all books
-- This query selects all records from the Books table to list all books.
SELECT * FROM Books;

-- List all borrowed books
-- This query selects details of all borrowed books, including the title, member name, borrow date, and return date.
SELECT b.Title, m.Name, br.BorrowDate, br.ReturnDate
FROM Borrowings br
JOIN Books b ON br.BookID = b.BookID
JOIN Members m ON br.MemberID = m.MemberID;

-- List overdue books
-- This query selects details of overdue books that have not been returned within 30 days of borrowing.
SELECT b.Title, m.Name, br.BorrowDate
FROM Borrowings br
JOIN Books b ON br.BookID = b.BookID
JOIN Members m ON br.MemberID = m.MemberID
WHERE br.ReturnDate IS NULL AND br.BorrowDate < CURDATE() - INTERVAL 30 DAY;

-- Aggregate function queries

-- 1. Total number of books borrowed
SELECT COUNT(*) AS total_books_borrowed FROM Borrowings;

-- 2. Number of books borrowed by each member
SELECT MemberID, COUNT(*) AS books_borrowed
FROM Borrowings
GROUP BY MemberID;

-- 3. Average borrowing duration for returned books
SELECT AVG(DATEDIFF(ReturnDate, BorrowDate)) AS avg_borrowing_duration
FROM Borrowings
WHERE ReturnDate IS NOT NULL;

-- 4. Total number of authors
SELECT COUNT(*) AS total_authors FROM Authors;

-- 5. Count of books by each author
SELECT AuthorID, COUNT(*) AS books_by_author
FROM Books
GROUP BY AuthorID;

-- 6. Member who has borrowed the most books
SELECT MemberID, COUNT(*) AS books_borrowed
FROM Borrowings
GROUP BY MemberID
ORDER BY books_borrowed DESC
LIMIT 1;

-- 7. Books borrowed in the last month
SELECT COUNT(*) AS books_borrowed_last_month
FROM Borrowings
WHERE BorrowDate >= CURDATE() - INTERVAL 1 MONTH;
