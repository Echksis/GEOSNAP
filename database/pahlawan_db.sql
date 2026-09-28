-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Sep 28, 2026 at 02:09 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pahlawan_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `comments`
--

CREATE TABLE `comments` (
  `id` int(11) NOT NULL,
  `hero_id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `comment` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `comments`
--

INSERT INTO `comments` (`id`, `hero_id`, `name`, `comment`, `created_at`) VALUES
(1, 1, 'Test', 'Test', '2026-09-27 21:35:57');

-- --------------------------------------------------------

--
-- Table structure for table `heroes`
--

CREATE TABLE `heroes` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `image` varchar(255) NOT NULL,
  `origin` varchar(100) NOT NULL,
  `lifetime` varchar(20) NOT NULL,
  `biography` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `heroes`
--

INSERT INTO `heroes` (`id`, `name`, `image`, `origin`, `lifetime`, `biography`) VALUES
(1, 'Ir. Soekarno', 'soekarno.jpg', 'Jawa Timur', '1901 - 1970', 'Ir. Soekarno adalah Proklamator Kemerdekaan Indonesia dan Presiden pertama Republik Indonesia. Beliau berperan penting dalam perjuangan kemerdekaan serta perumusan dasar negara Indonesia.'),
(2, 'Mohammad Hatta', 'hatta.jpg', 'Sumatera Barat', '1902 - 1980', 'Mohammad Hatta adalah Proklamator Kemerdekaan Indonesia dan Wakil Presiden pertama Republik Indonesia. Beliau dikenal sebagai tokoh penting dalam perjuangan kemerdekaan dan pengembangan demokrasi Indonesia.'),
(3, 'Jenderal Sudirman', 'sudirman.jpg', 'Jawa Tengah', '1916 - 1950', 'Jenderal Sudirman merupakan Panglima Besar Tentara Nasional Indonesia. Beliau memimpin perjuangan mempertahankan kemerdekaan Indonesia, termasuk melalui perang gerilya.'),
(4, 'Ki Hajar Dewantara', 'ki_hajar.jpg', 'Yogyakarta', '1889 - 1959', 'Ki Hajar Dewantara adalah tokoh pendidikan nasional Indonesia dan pendiri Perguruan Taman Siswa. Beliau memperjuangkan pendidikan yang dapat diakses oleh masyarakat Indonesia.'),
(5, 'R.A. Kartini', 'kartini.jpg', 'Jawa Tengah', '1879 - 1904', 'R.A. Kartini merupakan tokoh yang memperjuangkan pendidikan dan emansipasi perempuan Indonesia. Pemikiran dan surat-suratnya menjadi inspirasi bagi perkembangan pendidikan perempuan.'),
(6, 'Cut Nyak Dhien', 'cut_nyak_dien.jpg', 'Aceh', '1848 - 1908', 'Cut Nyak Dhien adalah pejuang perempuan dari Aceh yang melawan penjajahan Belanda. Beliau terus berjuang bersama pasukan Aceh dalam perang yang berlangsung selama bertahun-tahun.'),
(7, 'Cut Nyak Meutia', 'cut_nyak_meutia.jpg', 'Aceh', '1870 - 1910', 'Cut Nyak Meutia adalah pahlawan nasional dari Aceh yang berjuang melawan Belanda. Beliau dikenal karena keberanian dan kegigihannya dalam mempertahankan wilayah Aceh.'),
(8, 'Pangeran Diponegoro', 'diponegoro.jpg', 'Yogyakarta', '1785 - 1855', 'Pangeran Diponegoro adalah pemimpin Perang Jawa yang berlangsung pada tahun 1825 hingga 1830. Perjuangannya menjadi salah satu perlawanan besar terhadap pemerintahan kolonial Belanda.'),
(9, 'Pattimura', 'pattimura.jpg', 'Maluku', '1783 - 1817', 'Pattimura atau Thomas Matulessy adalah pejuang dari Maluku yang memimpin perlawanan terhadap Belanda pada tahun 1817. Ia menjadi simbol perjuangan rakyat Maluku.'),
(10, 'Sultan Hasanuddin', 'hassanudin.jpg', 'Sulawesi Selatan', '1631 - 1670', 'Sultan Hasanuddin adalah Sultan Gowa yang terkenal karena perlawanannya terhadap VOC. Karena keberaniannya, beliau mendapat julukan Ayam Jantan dari Timur.'),
(11, 'Tuanku Imam Bonjol', 'imam_bonjol.jpg', 'Sumatera Barat', '1772 - 1864', 'Tuanku Imam Bonjol merupakan pemimpin perjuangan dalam Perang Padri di Sumatera Barat. Beliau memimpin perlawanan terhadap kolonial Belanda dan menjadi salah satu tokoh penting dari Minangkabau.'),
(12, 'Bung Tomo', 'bung_tomo.jpg', 'Jawa Timur', '1920 - 1981', 'Bung Tomo adalah tokoh penting dalam Pertempuran Surabaya tahun 1945. Melalui pidato dan perjuangannya, beliau membangkitkan semangat rakyat Surabaya untuk mempertahankan kemerdekaan.'),
(13, 'Dewi Sartika', 'dewi_sartika.jpg', 'Jawa Barat', '1884 - 1947', 'Dewi Sartika adalah tokoh pendidikan dan pelopor pendidikan bagi perempuan di Indonesia. Beliau mendirikan Sakola Istri yang kemudian berkembang menjadi sekolah bagi kaum perempuan.'),
(14, 'Frans Kaisiepo', 'frans_kaisiepo.jpg', 'Papua', '1921 - 1979', 'Frans Kaisiepo merupakan tokoh perjuangan dari Papua yang berperan dalam mempertahankan integrasi Papua dengan Indonesia. Beliau juga pernah menjadi Gubernur Papua.'),
(15, 'I Gusti Ngurah Rai', 'ngurah_rai.jpg', 'Bali', '1917 - 1946', 'I Gusti Ngurah Rai adalah pejuang kemerdekaan dari Bali dan pemimpin pasukan Ciung Wanara. Beliau memimpin perjuangan melawan Belanda dalam Puputan Margarana.'),
(16, 'Raden Ajeng Siti Walidah', 'Raden.jpg', 'Yogyakarta', '1872 - 1946', 'Raden Ajeng Siti Walidah adalah tokoh pendidikan dan pergerakan perempuan Indonesia.'),
(17, 'Jendral Ahmad Yani', 'Ahmad Yani.jpg', 'Purworejo, Jawa Tengah', '1922–1965', 'Jenderal Ahmad Yani adalah pahlawan nasional Indonesia yang lahir di Purworejo pada 19 Juni 1922. Ia merupakan perwira tinggi TNI Angkatan Darat yang berperan dalam berbagai operasi militer untuk mempertahankan Indonesia. Ahmad Yani menjabat sebagai Menteri/Panglima Angkatan Darat dan gugur pada 1 Oktober 1965 dalam peristiwa G30S. Ia kemudian dianugerahi gelar Pahlawan Revolusi.');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `comments`
--
ALTER TABLE `comments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `hero_id` (`hero_id`);

--
-- Indexes for table `heroes`
--
ALTER TABLE `heroes`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `comments`
--
ALTER TABLE `comments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `heroes`
--
ALTER TABLE `heroes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `comments`
--
ALTER TABLE `comments`
  ADD CONSTRAINT `comments_ibfk_1` FOREIGN KEY (`hero_id`) REFERENCES `heroes` (`id`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
