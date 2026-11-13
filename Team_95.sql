CREATE DATABASE LocalDeliveryMarketplace_Team_95;
GO
USE LocalDeliveryMarketplace_Team_95;
GO

-- Rana Karim 64-5502
CREATE PROCEDURE createAllTables AS 
BEGIN 

     CREATE TABLE Zone(
           zone_id INT PRIMARY KEY IDENTITY(1,1),
           zone_name VARCHAR(50) NOT NULL UNIQUE,
           delivery_fee DECIMAL(10,2) NOT NULL,
           CONSTRAINT CHK_delivery_fee CHECK(delivery_fee>=0)
           );
    
    CREATE TABLE Users(
           user_id INT PRIMARY KEY IDENTITY(1,1),
           first_name VARCHAR(30) NOT NULL,
           middle_name VARCHAR(30),
           last_name VARCHAR(30) NOT NULL,
           username VARCHAR(30) NOT NULL UNIQUE,
           password VARCHAR(30) NOT NULL,
           email VARCHAR(100) NOT NULL UNIQUE,
           dob DATE,
           account_status VARCHAR(20) NOT NULL DEFAULT 'Active'
           );
    CREATE TABLE User_Phone(
           user_id INT NOT NULL ,
           phone CHAR(11) NOT NULL,
           PRIMARY KEY(user_id,phone),
           CONSTRAINT FK_User_Phone FOREIGN KEY (user_id) REFERENCES Users(user_id)
           );

    CREATE TABLE Admin(
           admin_id INT PRIMARY KEY,
           role VARCHAR(20) NOT NULL DEFAULT 'Super Admin',
           zone_id INT, 
           CONSTRAINT FK_Admin_User FOREIGN KEY (admin_id) REFERENCES Users(user_id),
           CONSTRAINT FK_Admin_Zone FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
           );

    CREATE TABLE Partner(
           partner_id INT PRIMARY KEY,
           CONSTRAINT FK_Partner_User FOREIGN KEY (partner_id) REFERENCES Users(user_id)
           );
    CREATE TABLE Rider(
           rider_id INT PRIMARY KEY,
           vehicle_type VARCHAR(30) NOT NULL ,
           plate_no VARCHAR(15) NOT NULL UNIQUE,
           license_no VARCHAR(20) NOT NULL UNIQUE,
           is_available BIT NOT NULL DEFAULT  1,
           zone_id INT NOT NULL ,
           CONSTRAINT FK_Rider_User FOREIGN KEY (rider_id) REFERENCES Users(user_id),
           CONSTRAINT FK_Partner_Zone FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
           );
    CREATE TABLE Customer(
           customer_id INT PRIMARY KEY ,
           wallet_balance DECIMAL(10,2) NOT NULL DEFAULT 0,
           CONSTRAINT FK_Customer_User FOREIGN KEY (customer_id) REFERENCES Users(user_id),
           CONSTRAINT CHK_wallet_balance CHECK(wallet_balance>=0)
           );
    CREATE TABLE Address(
           address_id INT PRIMARY KEY IDENTITY(1,1),
           description VARCHAR(150) NOT NULL,
           is_active BIT NOT NULL DEFAULT 1,
           customer_id INT NOT NULL ,
           zone_id INT NOT NULL,
           CONSTRAINT FK_Address_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
           CONSTRAINT FK_Address_Zone FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
           );
    CREATE TABLE Card(
           card_id INT PRIMARY KEY IDENTITY(1,1),
           card_no CHAR(16) NOT NULL,
           card_holder_name VARCHAR(100) NOT NULL,
           expiration_date DATE NOT NULL,
           customer_id INT NOT NULL ,
           CONSTRAINT FK_Card_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
           CONSTRAINT UQ_Card_Customer UNIQUE (customer_id,card_no)
           );
    CREATE TABLE Business(
           business_id INT PRIMARY KEY IDENTITY(1,1),
           name VARCHAR(100) NOT NULL,
           description VARCHAR(255),
           link_website VARCHAR(255),
           opening_hour TIME NOT NULL,
           closing_hour TIME NOT NULL,
           expected_delivery_time INT NOT NULL,
           status VARCHAR(20) NOT NULL DEFAULT 'Pending',
           suspension_reason VARCHAR(255),
           partner_id INT NOT NULL UNIQUE,
           zone_id INT NOT NULL,
           CONSTRAINT CHK_Business_delivery_time CHECK (expected_delivery_time > 0),
           CONSTRAINT CHK_Business_suspension CHECK (status = 'Suspended' OR suspension_reason IS NULL),
           CONSTRAINT FK_Business_Partner FOREIGN KEY (partner_id) REFERENCES Partner(partner_id),
           CONSTRAINT FK_Business_Zone FOREIGN KEY (zone_id) REFERENCES Zone(zone_id)
           );

     CREATE TABLE Business_Phone(
           business_id INT NOT NULL,
           phone CHAR(11) NOT NULL,
           CONSTRAINT PK_Business_Phone PRIMARY KEY (business_id, phone),
           CONSTRAINT FK_BusinessPhone_Business FOREIGN KEY (business_id) REFERENCES Business(business_id)
           );

     CREATE TABLE Restaurant(
           business_id INT PRIMARY KEY,
           cuisine_type VARCHAR(50) NOT NULL,
           food_category VARCHAR(50) NOT NULL,
           CONSTRAINT FK_Restaurant_Business FOREIGN KEY (business_id) REFERENCES Business(business_id)
      );

     CREATE TABLE Pharmacy(
           business_id INT PRIMARY KEY,
           pharmacy_type VARCHAR(50) NOT NULL,
           CONSTRAINT FK_Pharmacy_Business FOREIGN KEY (business_id) REFERENCES Business(business_id)
      );

      CREATE TABLE Blacklist(
           customer_id INT PRIMARY KEY,
           admin_id INT NOT NULL,
           reason VARCHAR(255) NOT NULL,
           CONSTRAINT FK_Blacklist_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
           CONSTRAINT FK_Blacklist_Admin FOREIGN KEY (admin_id) REFERENCES Admin(admin_id)
      );

      CREATE TABLE Product(
           product_id INT PRIMARY KEY IDENTITY(1,1),
           name VARCHAR(100) NOT NULL,
           description VARCHAR(255),
           category VARCHAR(50) NOT NULL,
           price DECIMAL(10,2) NOT NULL,
           discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
           is_available BIT NOT NULL DEFAULT 1,
           business_id INT NOT NULL,
           CONSTRAINT CHK_Product_price CHECK (price > 0),
           CONSTRAINT CHK_Product_discount CHECK (discount_amount >= 0 AND discount_amount <= 0.5 * price),
           CONSTRAINT FK_Product_Business FOREIGN KEY (business_id) REFERENCES Business(business_id)
      );
      CREATE TABLE Favorite_Business(
          customer_id INT NOT NULL,
          business_id INT NOT NULL,
          CONSTRAINT PK_Favorite_Business PRIMARY KEY (customer_id, business_id),
          CONSTRAINT FK_FavBusiness_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
          CONSTRAINT FK_FavBusiness_Business FOREIGN KEY (business_id) REFERENCES Business(business_id)
      );

     CREATE TABLE Favorite_Product(
         customer_id INT NOT NULL,
         product_id INT NOT NULL,
         CONSTRAINT PK_Favorite_Product PRIMARY KEY (customer_id, product_id),
         CONSTRAINT FK_FavProduct_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
         CONSTRAINT FK_FavProduct_Product FOREIGN KEY (product_id) REFERENCES Product(product_id)
     );

    CREATE TABLE Voucher(
         voucher_id INT PRIMARY KEY IDENTITY(1,1),
         promo_code VARCHAR(30) NOT NULL UNIQUE,
         is_percentage BIT NOT NULL,
         amount DECIMAL(10,2) NOT NULL,
         expiry_date DATE NOT NULL,
         status VARCHAR(20) NOT NULL DEFAULT 'Unused',
         customer_id INT NOT NULL,
         CONSTRAINT CHK_Voucher_amount CHECK (amount > 0),
         CONSTRAINT FK_Voucher_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id)
     );

    CREATE TABLE Cart(
         cart_id INT PRIMARY KEY IDENTITY(1,1),
         status VARCHAR(20) NOT NULL DEFAULT 'Active',
         created_at DATETIME NOT NULL DEFAULT GETDATE(),
         customer_id INT NOT NULL,
         address_id INT NOT NULL,
         CONSTRAINT FK_Cart_Customer FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),
         CONSTRAINT FK_Cart_Address FOREIGN KEY (address_id) REFERENCES Address(address_id)
     );

    CREATE TABLE CartItem(
        cart_id INT NOT NULL,
        product_id INT NOT NULL,
        quantity INT NOT NULL,
        notes VARCHAR(255),
        unit_price DECIMAL(10,2),
        CONSTRAINT PK_CartItem PRIMARY KEY (cart_id, product_id),
        CONSTRAINT CHK_CartItem_quantity CHECK (quantity BETWEEN 1 AND 10),
        CONSTRAINT FK_CartItem_Cart FOREIGN KEY (cart_id) REFERENCES Cart(cart_id),
        CONSTRAINT FK_CartItem_Product FOREIGN KEY (product_id) REFERENCES Product(product_id)
     );

    CREATE TABLE Orders(
        order_id INT PRIMARY KEY IDENTITY(1,1),
        order_date DATETIME NOT NULL,
        status VARCHAR(20) NOT NULL DEFAULT 'Placed',
        discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
        total_amount DECIMAL(10,2) NOT NULL,
        cart_id INT NOT NULL UNIQUE,
        zone_id INT NOT NULL,
        voucher_id INT,
        CONSTRAINT FK_Orders_Cart FOREIGN KEY (cart_id) REFERENCES Cart(cart_id),
        CONSTRAINT FK_Orders_Zone FOREIGN KEY (zone_id) REFERENCES Zone(zone_id),
        CONSTRAINT FK_Orders_Voucher FOREIGN KEY (voucher_id) REFERENCES Voucher(voucher_id)
     );

    CREATE TABLE SubOrder(
        suborder_id INT PRIMARY KEY IDENTITY(1,1),
        status VARCHAR(20) NOT NULL DEFAULT 'Placed',
        total_price DECIMAL(10,2) NOT NULL,
        delivery_fee DECIMAL(10,2) NOT NULL,
        order_id INT NOT NULL,
        business_id INT NOT NULL,
        CONSTRAINT UQ_SubOrder_Order_Business UNIQUE (order_id, business_id),
        CONSTRAINT FK_SubOrder_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id),
        CONSTRAINT FK_SubOrder_Business FOREIGN KEY (business_id) REFERENCES Business(business_id)
    );

   CREATE TABLE Delivery(
        delivery_id INT PRIMARY KEY IDENTITY(1,1),
        assigned_at DATETIME NOT NULL,
        picked_up_at DATETIME,
        delivered_at DATETIME,
        tracking_time INT,
        rider_rating INT,
        suborder_id INT NOT NULL UNIQUE,
        rider_id INT NOT NULL,
        CONSTRAINT CHK_Delivery_rating CHECK (rider_rating BETWEEN 1 AND 5),
        CONSTRAINT FK_Delivery_SubOrder FOREIGN KEY (suborder_id) REFERENCES SubOrder(suborder_id),
        CONSTRAINT FK_Delivery_Rider FOREIGN KEY (rider_id) REFERENCES Rider(rider_id)
   );

   CREATE TABLE Payment(
        payment_id INT PRIMARY KEY IDENTITY(1,1),
        amount DECIMAL(10,2) NOT NULL,
        currency VARCHAR(3) NOT NULL DEFAULT 'EGP',
        method VARCHAR(20) NOT NULL,
        transaction_date DATETIME NOT NULL,
        refunded_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
        order_id INT NOT NULL UNIQUE,
        card_id INT,
        CONSTRAINT CHK_Payment_refund CHECK (refunded_amount <= amount),
        CONSTRAINT FK_Payment_Orders FOREIGN KEY (order_id) REFERENCES Orders(order_id),
        CONSTRAINT FK_Payment_Card FOREIGN KEY (card_id) REFERENCES Card(card_id)
    );

   CREATE TABLE Feedback(
        feedback_id INT PRIMARY KEY IDENTITY(1,1),
        headline VARCHAR(100) NOT NULL,
        description VARCHAR(500),
        rating INT NOT NULL,
        feedback_date DATETIME NOT NULL DEFAULT GETDATE(),
        suborder_id INT NOT NULL UNIQUE,
        CONSTRAINT CHK_Feedback_rating CHECK (rating BETWEEN 1 AND 5),
        CONSTRAINT FK_Feedback_SubOrder FOREIGN KEY (suborder_id) REFERENCES SubOrder(suborder_id)
   );


 END
 GO






--ACTIVE VOUCHERS 4.2d --------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713
CREATE VIEW ActiveVouchers
AS
    SELECT voucher_id, promo_code, customer_id, is_percentage, amount, expiry_date
    FROM Voucher
    WHERE status='Unused' AND expiry_date >= CAST(GETDATE() AS DATE);
GO


--REGISTERS 4.3 a,b,c-------------------------------------------------------------------------------------------------------

-- Jodie Mahmoud Amam 64-2713
GO 
CREATE PROCEDURE Customer_Register
    @first_name VARCHAR(30),
    @middle_name VARCHAR(30),
    @last_name VARCHAR(30),
    @username VARCHAR(30),
    @password VARCHAR(30),
    @email VARCHAR(100),
    @phone CHAR(11),
    @dob date

    AS 
    BEGIN
        IF @first_name IS NULL 
            OR @last_name IS NULL OR @username IS NULL 
            OR @password IS NULL OR @email IS NULL 
            OR @phone IS NULL 
        RETURN -1;
        IF EXISTS (SELECT *
                    FROM Users
                    WHERE username=@username OR email=@email)
        RETURN -2;

        INSERT INTO Users (first_name, middle_name, last_name, username, password, email, dob)
        VALUES( @first_name, @middle_name,@last_name,@username,@password, @email,@dob);

        DECLARE @id INT = SCOPE_IDENTITY();
        INSERT INTO User_Phone(user_id, phone) VALUES (@id, @phone);
        INSERT INTO Customer(customer_id, wallet_balance) VALUES (@id, 0);

        RETURN 0;
    END;
 GO

-- Jodie Mahmoud Amam 64-2713
GO 
CREATE PROCEDURE Partner_Register
    @first_name VARCHAR(30),
    @middle_name VARCHAR(30),
    @last_name VARCHAR(30),
    @username VARCHAR(30),
    @password VARCHAR(30),
    @email VARCHAR(100),
    @phone CHAR(11),
    @dob date

    AS 
    BEGIN
        IF @first_name IS NULL 
            OR @last_name IS NULL OR @username IS NULL 
            OR @password IS NULL OR @email IS NULL 
            OR @phone IS NULL 
        RETURN -1;
        IF EXISTS (SELECT *
                    FROM Users
                    WHERE username=@username OR email=@email)
        RETURN -2;

        INSERT INTO Users (first_name, middle_name, last_name, username, password, email, dob)
        VALUES( @first_name, @middle_name,@last_name,@username,@password, @email,@dob);

        DECLARE @id INT = SCOPE_IDENTITY();
        INSERT INTO User_Phone(user_id, phone) VALUES (@id, @phone);
        INSERT INTO Partner(partner_id) VALUES (@id);

        RETURN 0;
    END;
 GO

 -- Jodie Mahmoud Amam 64-2713
GO 
CREATE PROCEDURE Rider_Register
    @first_name VARCHAR(30),
    @middle_name VARCHAR(30),
    @last_name VARCHAR(30),
    @username VARCHAR(30),
    @password VARCHAR(30),
    @email VARCHAR(100),
    @phone CHAR(11),
    @dob date,
    @vehicle_type VARCHAR(30),
    @plate_no VARCHAR(15),
    @license_no VARCHAR(20),
    @zone_id INT

    AS 
    BEGIN
        IF @first_name IS NULL 
            OR @last_name IS NULL OR @username IS NULL 
            OR @password IS NULL OR @email IS NULL 
            OR @phone IS NULL OR @vehicle_type IS NULL 
            OR @plate_no IS NULL OR @license_no IS NULL
        RETURN -1;

        IF NOT EXISTS (SELECT *
                    FROM Zone
                    WHERE zone_id=@zone_id)
        RETURN -1;

        IF EXISTS (SELECT *
                    FROM Users
                    WHERE username=@username OR email=@email)
        RETURN -2;

        IF EXISTS (SELECT *
                    FROM Rider
                    WHERE plate_no=@plate_no OR license_no=@license_no)
        RETURN -2;

        INSERT INTO Users (first_name, middle_name, last_name, username, password, email, dob)
        VALUES( @first_name, @middle_name,@last_name,@username,@password, @email,@dob);

        DECLARE @id INT = SCOPE_IDENTITY();
        INSERT INTO User_Phone(user_id, phone) VALUES (@id, @phone);
        INSERT INTO Rider(rider_id, vehicle_type, plate_no, license_no, is_available, zone_id)
        VALUES (@id, @vehicle_type, @plate_no, @license_no, 1, @zone_id);

        RETURN 0;
    END;
 GO


--LOGIN FUNCTION  4.3 d,e,f,g-------------------------------------------------------------------------------------------------------

-- Jodie Mahmoud Amam 64-2713
GO 
CREATE FUNCTION CustomerLoginValidation
    (@username VARCHAR(30), @password VARCHAR(30))
    RETURNS bit

    AS
    BEGIN
        IF EXISTS(  SELECT *
                    FROM Users U
                    INNER JOIN Customer C ON U.user_id=C.customer_id
                    WHERE U.username=@username AND U.password=@password AND U.account_status='Active')
            RETURN 1;
        RETURN 0;
    END;
GO

-- Jodie Mahmoud Amam 64-2713
GO 
CREATE FUNCTION PartnerLoginValidation
    (@username VARCHAR(30), @password VARCHAR(30))
    RETURNS bit

    AS
    BEGIN
        IF EXISTS(  SELECT *
                    FROM Users U
                    INNER JOIN Partner P ON U.user_id=P.partner_id
                    WHERE U.username=@username AND U.password=@password AND U.account_status='Active')
            RETURN 1;
        RETURN 0;
    END;
GO

-- Jodie Mahmoud Amam 64-2713
GO 
CREATE FUNCTION RiderLoginValidation
    (@username VARCHAR(30), @password VARCHAR(30))
    RETURNS bit

    AS
    BEGIN
        IF EXISTS(  SELECT *
                    FROM Users U
                    INNER JOIN  Rider R ON U.user_id=R.rider_id
                    WHERE U.username=@username AND U.password=@password AND U.account_status='Active')
            RETURN 1;
        RETURN 0;
    END;
GO

-- Jodie Mahmoud Amam 64-2713
GO 
CREATE FUNCTION AdminLoginValidation
    (@username VARCHAR(30), @password VARCHAR(30))
    RETURNS bit

    AS
    BEGIN
        IF EXISTS(  SELECT *
                    FROM Users U
                    INNER JOIN Admin A ON U.user_id=A.admin_id
                    WHERE U.username=@username AND U.password=@password AND U.account_status='Active')
            RETURN 1;
        RETURN 0;
    END;
GO

--CHANGE PASSWORD. 4.3 h-------------------------------------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713
GO 
CREATE PROCEDURE Change_Password
    @user_id INT, 
    @old_password VARCHAR(30),
    @new_password VARCHAR(30),
    @new_password_repeat VARCHAR(30),
    @success bit OUTPUT

    AS
    BEGIN
        SET @success=0;
        IF NOT EXISTS( SELECT *                     --bat2aked en this user exists aslan
                        FROM Users
                        WHERE user_id=@user_id AND password=@old_password)
            RETURN -1;
        
        IF @new_password IS NULL OR @new_password_repeat IS NULL OR @new_password <> @new_password_repeat OR @new_password=@old_password
        RETURN -1;

        UPDATE Users SET password=@new_password
                    WHERE user_id=@user_id;
        SET @success=1;
        RETURN 0;
    END;
GO

--CREATE ADMIN  4.4 a---------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713

GO 
CREATE PROCEDURE Create_Admin
    @first_name VARCHAR(30),
    @middle_name VARCHAR(30),
    @last_name VARCHAR(30),
    @username VARCHAR(30),
    @password VARCHAR(30),
    @email VARCHAR(100),
    @phone CHAR(11),
    @dob date,
    @role VARCHAR(20),
    @zone_id INT,
    @super_admin_id INT

    AS
    BEGIN
        IF NOT EXISTS ( SELECT * 
                        FROM Admin 
                        WHERE admin_id = @super_admin_id AND role = 'Super Admin')
            RETURN -3;

        IF @role IS NULL
            SET @role = 'Super Admin';
        
        IF @role <> 'Super Admin' AND @role <> 'Zone Admin'
            RETURN -1;

        IF @first_name IS NULL OR @last_name IS NULL 
            OR @username IS NULL OR @password IS NULL 
            OR @email IS NULL OR @phone IS NULL
        RETURN -1;

        IF @role ='Zone Admin' 
            BEGIN
                IF NOT EXISTS (SELECT *
                                FROM Zone
                                WHERE zone_id=@zone_id)
                RETURN -1;
            END
        ELSE 
        BEGIN
            IF @zone_id IS NOT NULL
                RETURN -1;
        END

        IF EXISTS ( SELECT *
                    FROM Users
                    WHERE username=@username or email=@email)
            RETURN -2;
        
        INSERT INTO Users (first_name, middle_name, last_name, username, password, email, dob)
        VALUES( @first_name, @middle_name,@last_name,@username,@password, @email,@dob);

        DECLARE @id INT = SCOPE_IDENTITY();
        INSERT INTO User_Phone(user_id, phone) VALUES (@id, @phone);
        INSERT INTO Admin(admin_id, role, zone_id) VALUES (@id, @role, @zone_id);

        RETURN 0;
    END;
GO

--APPROVE BUSINES 4.4 b---------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713

GO 
CREATE PROCEDURE Approve_Business
    @business_id INT,
    @admin_id INT

    AS 
    BEGIN
        DECLARE @role VARCHAR(20), @admin_zone INT, @status VARCHAR(20), @business_zone INT;

        SELECT @role=role , @admin_zone=zone_id 
        FROM Admin
        WHERE admin_id=@admin_id;

        IF @role IS NULL 
        RETURN -3;  --this is not an admin

        SELECT @status=status, @business_zone=zone_id 
        FROM Business
        WHERE business_id=@business_id;

        IF @status IS NULL 
        RETURN -1;  --mafeesh business

        IF @role='Zone Admin' AND @admin_zone<>@business_zone
        RETURN -3;  --makes sure that zone admin works f one zone only

        IF @status<>'Pending'
        RETURN -4;

        UPDATE Business SET status='Active'
            WHERE business_id=@business_id;
        
        RETURN 0;
    END;
GO

--REJECT BUSINESS. 4.4 c---------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713

GO 
CREATE PROCEDURE Reject_Business
    @business_id INT,
    @admin_id INT

    AS 
    BEGIN
        DECLARE @role VARCHAR(20), @admin_zone INT, @status VARCHAR(20), @business_zone INT;

        SELECT @role=role , @admin_zone=zone_id 
        FROM Admin
        WHERE admin_id=@admin_id;

        IF @role IS NULL 
        RETURN -3;  --this is not an admin

        SELECT @status=status, @business_zone=zone_id 
        FROM Business
        WHERE business_id=@business_id;

        IF @status IS NULL 
        RETURN -1;  --mafeesh business

        IF @role='Zone Admin' AND @admin_zone<>@business_zone
        RETURN -3;  --makes sure that zone admin works f one zone only

        IF @status<>'Pending'
        RETURN -4;

        UPDATE Business SET status='Rejected'
            WHERE business_id=@business_id;
        
        RETURN 0;
    END;
GO


--ASSIGN ADMIN ZONE  4.4 h---------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713
GO 
CREATE PROCEDURE Assign_Admin_Zone
       @admin_id INT, 
       @zone_id INT,
       @super_admin_id INT

    AS
    BEGIN
       IF NOT EXISTS (SELECT *
                      FROM Admin 
                      WHERE admin_id = @super_admin_id AND role = 'Super Admin')
              RETURN -3;

       DECLARE @curr_role varchar(20);
       SELECT @curr_role = role 
       FROM Admin 
       WHERE admin_id = @admin_id;

       IF @curr_role IS NULL
        RETURN -1;       -- this person is not an admin

       IF @curr_role <> 'Zone Admin'
        RETURN -3;         -- only zone admins need a zone
       
        IF NOT EXISTS (SELECT * 
                       FROM Zone 
                       WHERE zone_id = @zone_id)
              RETURN -1;

       UPDATE Admin SET zone_id = @zone_id 
              WHERE admin_id = @admin_id;
        RETURN 0;
     END;
GO

--ISSUE VOUCHER  4.4 i---------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713
GO
CREATE PROCEDURE Issue_Voucher
    @customer_id INT,
    @promo_code VARCHAR(30),
    @is_percentage BIT,
    @amount DECIMAL(10,2),
    @expiry_date DATE,
    @admin_id INT
  
AS
BEGIN
    IF NOT EXISTS (SELECT *
                    FROM Admin
                    WHERE admin_id=@admin_id)
            RETURN -3;
    
    IF NOT EXISTS (SELECT *
                    FROM Customer
                    WHERE customer_id=@customer_id)
            RETURN -1;

    IF EXISTS (SELECT *
                FROM Users
                WHERE user_id=@customer_id AND account_status='Blacklisted')
            RETURN -3;          -- blacklisted customer
  ------- dol el conditions              
                IF @promo_code IS NULL OR @is_percentage IS NULL OR @amount IS NULL OR @expiry_date IS NULL
                RETURN -1;

                IF @amount<=0
                RETURN -1;

                IF @is_percentage=1 AND (@amount<1 OR @amount>100)
                RETURN -1;
                
                IF @expiry_date < CAST(GETDATE()AS DATE) 
                RETURN -1;

    IF EXISTS (SELECT *
                FROM Voucher
                WHERE promo_code=@promo_code)
            RETURN -2;          -- el voucher da already mawgood fel table

    INSERT INTO Voucher (promo_code, is_percentage, amount, expiry_date, status, customer_id)
    VALUES (@promo_code, @is_percentage, @amount, @expiry_date, 'Unused', @customer_id);

    RETURN 0;
END;
GO


-- BLACKLIST CUSTOMER 4.4 j--------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713
GO
CREATE PROCEDURE Blacklist_Customer
    @customer_id INT, 
    @admin_id INT,
    @reason VARCHAR(255)

AS
BEGIN


    IF NOT EXISTS (SELECT *
                    FROM Admin
                    WHERE admin_id=@admin_id)
            RETURN -3;

    IF NOT EXISTS ( SELECT *
                    FROM Customer
                    WHERE customer_id=@customer_id)
            RETURN -1;

    IF @reason IS NULL
          RETURN -1;
    
    IF EXISTS ( SELECT *
                FROM Blacklist
                WHERE customer_id=@customer_id)
            RETURN -2;   -- reject el kan already blacklisted
        
    IF EXISTS ( SELECT *
                FROM Admin
                WHERE admin_id=@admin_id AND role='Zone Admin')
            BEGIN
                IF NOT EXISTS ( SELECT *
                                FROM Address A
                                INNER JOIN Admin Adm ON A.zone_id=Adm.zone_id
                                WHERE A.customer_id=@customer_id AND Adm.admin_id=@admin_id)
                        RETURN -3;
            END;                --  zone admin bas beyblacklist customers in their zone

-- hena ana ba blacklist
    UPDATE Users SET account_status='Blacklisted'
        WHERE user_id=@customer_id;

    INSERT INTO Blacklist (customer_id, admin_id, reason)
    VALUES (@customer_id, @admin_id, @reason);

-- save all the orders that need to be cancelled f a new table
    DECLARE @order TABLE (order_id INT)

    INSERT INTO @order (order_id)
            SELECT O.order_id
            FROM Orders O
            INNER JOIN Cart C ON O.cart_id = C.cart_id
            WHERE C.customer_id=@customer_id AND O.status <> 'Cancelled' AND NOT EXISTS ( SELECT *
                                                                                            FROM Suborder S
                                                                                            WHERE S.order_id=O.order_id AND (S.status='Delivered' OR S.status='Picked Up'));

-- bashoof ad eh hayerga3 to the wallet (bas msh el cash)
    DECLARE @refund DECIMAL(10,2);

    SELECT @refund= SUM(P.amount -P.refunded_amount)
    FROM Payment P
    INNER JOIN @order X ON X.order_id=P.order_id
    WHERE P.method<> 'Cash';

-- if nothing was added
    IF @refund IS NULL
        SET @refund = 0;

-- adding the money back to the wallet
    UPDATE Customer SET wallet_balance= wallet_balance + @refund
        WHERE customer_id=@customer_id;

-- ba update el payments table
    UPDATE P SET P.refunded_amount = P.amount
    FROM Payment P
    INNER JOIN @order X ON X.order_id=P.order_id;

-- cancel el suborders wel orders
    UPDATE S SET S.status = 'Cancelled'
    FROM SubOrder S
    INNER JOIN @order X ON X.order_id = S.order_id
    WHERE S.status <> 'Cancelled';

    UPDATE O SET O.status = 'Cancelled'
    FROM Orders O
    INNER JOIN @order X ON X.order_id = O.order_id;

-- basheel el vouchers el kano fel cancelled orders w ba consider them unused aashan homa keda mahadesh estakhdemhom
    UPDATE V SET V.status = 'Unused'
    FROM Voucher V
    INNER JOIN Orders O ON O.voucher_id = V.voucher_id
    INNER JOIN @order X ON X.order_id = O.order_id;

    UPDATE O SET O.voucher_id = NULL
    FROM Orders O
    INNER JOIN @order X ON X.order_id = O.order_id;

-- delete the blacklisted customer's unused vouchers from the table
    DELETE FROM Voucher 
    WHERE customer_id = @customer_id AND status = 'Unused';

    RETURN 0;
END;
GO


--LIFT CUSTOMER BLACKLIST  4.4 k--------------------------------------------------------------------------
--Jodie Mahmoud Amam 64-2713

GO 
CREATE PROCEDURE Lift_Customer_Blacklist
    @customer_id INT,
    @admin_id INT

AS 
BEGIN

    IF NOT EXISTS ( SELECT *
                    FROM Admin
                    WHERE admin_id=@admin_id)
            RETURN -3;
    
    IF NOT EXISTS ( SELECT *
                    FROM Customer
                    WHERE customer_id=@customer_id)
            RETURN -1;

   IF NOT EXISTS ( SELECT *
                    FROM Blacklist
                    WHERE customer_id=@customer_id)
            RETURN -4;          --bat2aked en da el customer el blacklisted
    
   IF NOT EXISTS ( SELECT *
                    FROM Blacklist
                    WHERE customer_id=@customer_id AND admin_id=@admin_id)
            RETURN -3;          -- bat2aked en da el admin el aamalo blacklist

    UPDATE Users SET account_status='Active'
        WHERE user_id=@customer_id;
    DELETE FROM Blacklist 
        WHERE customer_id=@customer_id;
    
    RETURN 0;
END;
GO


