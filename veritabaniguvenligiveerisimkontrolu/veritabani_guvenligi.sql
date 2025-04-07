-- ADIM 1: VERİTABANI VE TABLO OLUŞTURMA
CREATE DATABASE KullaniciDB;
GO

USE KullaniciDB;
GO

CREATE TABLE Kullanicilar (
    KullaniciID INT PRIMARY KEY IDENTITY(1,1),
    KullaniciAdi NVARCHAR(50),
    Sifre NVARCHAR(100),
    Email NVARCHAR(100)
);
GO

INSERT INTO Kullanicilar (KullaniciAdi, Sifre, Email)
VALUES
('admin', 'admin123', 'admin@example.com'),
('mehmet', '1234', 'mehmet@example.com'),
('ahmet', 'ahmet123', 'ahmet@example.com');
GO


-- ADIM 2: KULLANICI OLUŞTURMA VE YETKİ VERME
CREATE LOGIN ornek_kullanici
WITH PASSWORD = 'GGuvenliSifre123!';
GO

USE KullaniciDB;
GO

CREATE USER ornek_kullanici FOR LOGIN ornek_kullanici;
GO

GRANT SELECT ON Kullanicilar TO ornek_kullanici;
GO


-- ADIM 3: SQL INJECTION KÖTÜ ÖRNEK (SADECE TEST AMAÇLI!)
-- Bu örnek sadece yöneticiler tarafından test edilir.
DECLARE @kullanici NVARCHAR(100) = 'admin'' OR ''1''=''1';
DECLARE @sorgu NVARCHAR(MAX) = 
    'SELECT * FROM Kullanicilar WHERE KullaniciAdi = ''' + @kullanici + '''';

EXEC(@sorgu);
GO


-- ADIM 3: SQL INJECTION'A KARŞI GÜVENLİ YÖNTEM
CREATE PROCEDURE SP_KullaniciGiris
    @KullaniciAdi NVARCHAR(100)
AS
BEGIN
    SELECT * FROM Kullanicilar
    WHERE KullaniciAdi = @KullaniciAdi;
END;
GO

-- Kullanım örneği:
-- EXEC SP_KullaniciGiris @KullaniciAdi = 'admin';


-- ADIM 4: VERİ MASKELEME (SİFRE ALANI)
ALTER TABLE Kullanicilar
ALTER COLUMN Sifre ADD MASKED WITH (FUNCTION = 'default()');
GO

-- (İsteğe Bağlı) Maske görme yetkisini engelle:
REVOKE UNMASK TO ornek_kullanici;
GO


-- ADIM 5: AUDIT LOG SORGUSU
-- (Bu komut log okumak içindir, audit tanımını içermez)
SELECT
    event_time,
    action_id,
    succeeded,
    session_server_principal_name,
    database_name,
    object_name,
    statement
FROM sys.fn_get_audit_file (
    'D:\AuditLogs\*.sqlaudit',
    DEFAULT,
    DEFAULT
)
ORDER BY event_time DESC;
GO
