-- +goose Up
    create table auth_user (
        id serial primary key,
        name text not null,
        body text not null,
        created_at timestamp not null default now(),
        updated_at timestamp
    );
-- +goose StatementBegin
-- SELECT 'up SQL query';
-- +goose StatementEnd

-- +goose Down
    drop table auth_user;
-- +goose StatementBegin
-- SELECT 'down SQL query';
-- +goose StatementEnd