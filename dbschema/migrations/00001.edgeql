CREATE MIGRATION m1yo7dmb5ckunrljqckwejo7sg7znarwe7ovmubgkca4fggdrgz3uq
    ONTO initial
{
  CREATE GLOBAL default::current_user_id -> std::uuid;
  CREATE TYPE default::User;
  CREATE TYPE default::Post {
      CREATE REQUIRED LINK author -> default::User;
      CREATE LINK reviewer -> default::User {
          CREATE CONSTRAINT std::exclusive;
      };
      CREATE CONSTRAINT std::expression ON (NOT ((.author IN .reviewer)));
  };
  ALTER TYPE default::User {
      CREATE MULTI LINK posts -> default::Post {
          CREATE CONSTRAINT std::exclusive;
      };
  };
  CREATE GLOBAL default::current_user := (SELECT
      default::User
  FILTER
      (.id = GLOBAL default::current_user_id)
  );
  ALTER TYPE default::Post {
      CREATE ACCESS POLICY any_insert
          ALLOW INSERT USING (EXISTS (GLOBAL default::current_user));
      CREATE ACCESS POLICY author_read
          ALLOW SELECT, UPDATE USING ((GLOBAL default::current_user ?= .author));
      CREATE ACCESS POLICY reviewer_read
          ALLOW SELECT, UPDATE USING (((GLOBAL default::current_user IN .reviewer) ?? false));
  };
};
