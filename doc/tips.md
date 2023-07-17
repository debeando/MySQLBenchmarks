# Tips

## CHAR vs VARCHAR

There is insignificant difference especially considering CHAR has a maximum length of 255 (VARCHAR is 64K). With the effective equivalent limited to 255 that is a very quick comparison in the case of this field being used as join criteria.

The fragmentation is no longer an consideration as <768 bytes is stored inline. This is still strictly possible in utf8mb4, "InnoDB encodes fixed-length fields greater than or equal to 768 bytes in length as variable-length fields"1 so no difference between CHAR and VARCHAR.

https://dev.mysql.com/doc/refman/8.0/en/char.html
