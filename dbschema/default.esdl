module default {
    global current_user_id -> uuid;
    global current_user := (
        select User filter .id = global current_user_id
    );

    type User {
        multi link posts -> Post {
            constraint exclusive;
        }
    }

    type Post {
        required link author -> User;
        link reviewer -> User {
            constraint exclusive;
        };

        constraint expression on (
            not (.author in .reviewer)
        );

        access policy any_insert allow insert using (
            exists global current_user
        );

        access policy author_read allow select, update using (
            (global current_user ?= .author)
        );

        access policy reviewer_read allow select, update using (
            ((global current_user in .reviewer) ?? false)
        );
    }
}
