#CREATE TABLES
use fingertips;

CREATE TABLE Users (
  user_id INT PRIMARY KEY,
  username VARCHAR(50),
  email VARCHAR(100),
  password VARCHAR(100),
  registration_date DATE
);

-- Playlist table
CREATE TABLE Playlists (
  playlist_id INT PRIMARY KEY,
  playlist_name VARCHAR(100),
  user_id INT,
  created_at DATE,
  FOREIGN KEY (user_id) REFERENCES Users(user_id)
);

-- Track table
CREATE TABLE Tracks (
  track_id INT PRIMARY KEY,
  track_name VARCHAR(100),
  artist_name VARCHAR(100),
  album_name VARCHAR(100),
  duration INT, 
  release_date DATE
);

-- PlaylistTrack table
CREATE TABLE PlaylistTracks (
  playlist_id INT,
  track_id INT,
  position INT,
  FOREIGN KEY (playlist_id) REFERENCES Playlists(playlist_id),
  FOREIGN KEY (track_id) REFERENCES Tracks(track_id)
);

#INSERT VALUES IN TABLES
-- Insert values into Users table
INSERT INTO Users (user_id, username, email, password, registration_date)
VALUES

-- Insert values into Playlists table
INSERT INTO Playlists (playlist_id, playlist_name, user_id, created_at)
VALUES

  
-- Insert values into Tracks table
INSERT INTO Tracks (track_id, track_name, artist_name, album_name, duration, release_date)
VALUES
  
  
-- Insert values into PlaylistTracks table
INSERT INTO PlaylistTracks (playlist_id, track_id, position)
VALUES
  
select * from users;
select * from Playlists;
select * from Tracks;
select * from PlaylistTracks;


-- 1. Find all the distinct album names.
SELECT DISTINCT album_name 
FROM Tracks;


-- 2. Who is the artist of song 'Never Seen the Rain'?
SELECT artist_name 
FROM Tracks
WHERE track_name = 'Never Seen the Rain';


-- 3. Name all the user & email, who have registered with gmail id.
SELECT username, email
FROM Users
WHERE email LIKE '%@gmail.com';


-- 4. List the name of users along with registration dates, who have registered after April-22.
SELECT username, registration_date
FROM Users
WHERE registration_date > '2022-04-30';


-- 5. Extract the name of tracks, artists, albums and release dates for tracks released in year 2017
SELECT track_name, artist_name, album_name, release_date
FROM Tracks
WHERE YEAR(release_date) = 2017;


-- 6. Find the details of the users who have registered in between May and August.
SELECT *
FROM Users
WHERE MONTH(registration_date) BETWEEN 5 AND 8;


-- 7. Count the number of playlists created by each user.
SELECT user_id, COUNT(playlist_id) AS total_playlists
FROM Playlists
GROUP BY user_id;


-- 8. Find the track names and their durations for a specific album in the Tracks table.
SELECT track_name, duration
FROM Tracks
WHERE album_name = 'After Hours';


-- 9. Calculate the average duration of tracks in the Tracks table.
SELECT AVG(duration) AS avg_duration
FROM Tracks;


-- 10. How many users have registered with yahoo.com id?
SELECT COUNT(*) AS yahoo_users
FROM Users
WHERE email LIKE '%@yahoo.com';




-- 1. Find the playlist names and the number of tracks in each playlist created by users whose email addresses end with '@gmail.com'.
SELECT p.playlist_name, COUNT(pt.track_id) AS total_tracks
FROM Playlists p
JOIN Users u ON p.user_id = u.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
WHERE u.email LIKE '%@gmail.com'
GROUP BY p.playlist_id, p.playlist_name;


-- 2. Retrieve usernames and emails of users who created playlists with >5 tracks and avg track duration >200 sec
SELECT u.username, u.email
FROM Users u
JOIN Playlists p ON u.user_id = p.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
GROUP BY u.user_id, u.username, u.email
HAVING COUNT(pt.track_id) > 5 AND AVG(t.duration) > 200;


-- 3. Find tracks with duration greater than average duration of all tracks
SELECT track_name, artist_name
FROM Tracks
WHERE duration > (SELECT AVG(duration) FROM Tracks);


-- 4. Find users who have created playlists with tracks from all albums released in a specific year (example: 2019)
SELECT DISTINCT u.username
FROM Users u
JOIN Playlists p ON u.user_id = p.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
WHERE YEAR(t.release_date) = 2019
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT t.album_name) = 
(
  SELECT COUNT(DISTINCT album_name)
  FROM Tracks
  WHERE YEAR(release_date) = 2019
);


-- 5. Name of playlist and their total durations, sorted by number of tracks in descending order
SELECT p.playlist_name,
       SUM(t.duration) AS total_duration,
       COUNT(pt.track_id) AS total_tracks
FROM Playlists p
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
GROUP BY p.playlist_id, p.playlist_name
ORDER BY total_tracks DESC;


-- 6. Find playlists that have tracks longer than average duration of all tracks
SELECT DISTINCT p.playlist_name
FROM Playlists p
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
WHERE t.duration > (SELECT AVG(duration) FROM Tracks);


-- 7. Find top 3 playlists with most tracks
SELECT p.playlist_name, COUNT(pt.track_id) AS total_tracks
FROM Playlists p
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_id, p.playlist_name
ORDER BY total_tracks DESC
LIMIT 3;


-- 8. Calculate average track duration for each user (descending order)
SELECT u.username, AVG(t.duration) AS avg_duration
FROM Users u
JOIN Playlists p ON u.user_id = p.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
GROUP BY u.user_id, u.username
ORDER BY avg_duration DESC;


-- 9. Find tracks included in at least two different playlists
SELECT t.track_name, t.artist_name
FROM Tracks t
JOIN PlaylistTracks pt ON t.track_id = pt.track_id
GROUP BY t.track_id, t.track_name, t.artist_name
HAVING COUNT(DISTINCT pt.playlist_id) >= 2;


-- 10. Playlist names and total duration, only for users registered in 2022
SELECT p.playlist_name, SUM(t.duration) AS total_duration
FROM Playlists p
JOIN Users u ON p.user_id = u.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
WHERE YEAR(u.registration_date) = 2022
GROUP BY p.playlist_id, p.playlist_name;


-- 1. Tracks in playlists created by users registered before avg registration date
SELECT DISTINCT t.track_name, t.artist_name
FROM Tracks t
JOIN PlaylistTracks pt ON t.track_id = pt.track_id
JOIN Playlists p ON pt.playlist_id = p.playlist_id
JOIN Users u ON p.user_id = u.user_id
WHERE u.registration_date < (SELECT AVG(registration_date) FROM Users);


-- 2. Users who created playlists containing tracks from BOTH albums
SELECT DISTINCT u.username
FROM Users u
JOIN Playlists p ON u.user_id = p.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
WHERE t.album_name IN ('After Hours', 'When We All Fall Asleep, Where Do We Go?')
GROUP BY u.user_id, u.username
HAVING COUNT(DISTINCT t.album_name) = 2;


-- 3. Top 3 users with highest average track duration
SELECT u.username, AVG(t.duration) AS avg_duration
FROM Users u
JOIN Playlists p ON u.user_id = p.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
GROUP BY u.user_id, u.username
ORDER BY avg_duration DESC
LIMIT 3;


-- 4. Tracks > avg duration and rank within their albums
SELECT track_name, artist_name, album_name, duration,
       RANK() OVER (PARTITION BY album_name ORDER BY duration DESC) AS rank_in_album
FROM Tracks
WHERE duration > (SELECT AVG(duration) FROM Tracks);


-- 5. Playlist name, total tracks and rank based on track count
SELECT p.playlist_name,
       COUNT(pt.track_id) AS total_tracks,
       RANK() OVER (ORDER BY COUNT(pt.track_id) DESC) AS playlist_rank
FROM Playlists p
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_id, p.playlist_name;


-- 6. Users who created playlists with highest number of tracks from a specific artist (example: Ed Sheeran)
SELECT u.username, COUNT(t.track_id) AS total_tracks
FROM Users u
JOIN Playlists p ON u.user_id = p.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
WHERE t.artist_name = 'Ed Sheeran'
GROUP BY u.user_id, u.username
ORDER BY total_tracks DESC;


-- 7. Top users with highest number of UNIQUE tracks from a specific artist (example: The Weeknd)
SELECT u.username, COUNT(DISTINCT t.track_id) AS unique_tracks
FROM Users u
JOIN Playlists p ON u.user_id = p.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
WHERE t.artist_name = 'The Weeknd'
GROUP BY u.user_id, u.username
ORDER BY unique_tracks DESC
LIMIT 3;


-- 8. Tracks longer than avg duration within their own album
SELECT t.track_name, t.artist_name, t.album_name, t.duration
FROM Tracks t
WHERE t.duration > (
    SELECT AVG(t2.duration)
    FROM Tracks t2
    WHERE t2.album_name = t.album_name
);


-- 9. Playlist name with user, sorted by track count DESC and username ASC
SELECT p.playlist_name, u.username, COUNT(pt.track_id) AS total_tracks
FROM Playlists p
JOIN Users u ON p.user_id = u.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
GROUP BY p.playlist_id, p.playlist_name, u.username
ORDER BY total_tracks DESC, u.username ASC;


-- 10. Playlist, user, and position of longest track in each playlist
SELECT p.playlist_name, u.username, pt.position, t.duration
FROM Playlists p
JOIN Users u ON p.user_id = u.user_id
JOIN PlaylistTracks pt ON p.playlist_id = pt.playlist_id
JOIN Tracks t ON pt.track_id = t.track_id
WHERE (p.playlist_id, t.duration) IN (
    SELECT pt2.playlist_id, MAX(t2.duration)
    FROM PlaylistTracks pt2
    JOIN Tracks t2 ON pt2.track_id = t2.track_id
    GROUP BY pt2.playlist_id
);
