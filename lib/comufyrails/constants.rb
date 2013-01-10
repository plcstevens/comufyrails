module Comufyrails
  # String data accepted (this is the usual type to use)
  STRING_TYPE = "STRING"
  # Date data (1988-10-01 19:50:48 YYYY-MM-DD HH:mm:SS)
  DATE_TYPE   = "DATE"
  # Gender data (TODO: format?)
  GENDER_TYPE = "GENDER"
  # Integer data accepted (32-bit)
  INT_TYPE    = "INT"
  # Float data accepted (32-bit float)
  FLOAT_TYPE  = "FLOAT"
  # Data types must be one of these formats
  LEGAL_TYPES = [STRING_TYPE, DATE_TYPE, GENDER_TYPE, INT_TYPE, FLOAT_TYPE]

  # Name tags
  NAME_TAG    = :name
  # Type tags
  TYPE_TAG    = :type
  # Allowed tag keys
  LEGAL_TAGS  = [NAME_TAG, TYPE_TAG]
end
