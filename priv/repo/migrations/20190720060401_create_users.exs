defmodule Zz.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :address, :string
      add :arti_person, :string
      add :arti_phone, :string
      add :bank_id, :string
      add :busi_name, :string
      add :busi_type, :string
      add :cert_code, :string
      add :cust_id, :string
      add :deposit_bank, :string
      add :email, :string
      add :fax, :string
      add :link_mane, :string
      add :link_phone, :string
      add :manage_type, :string
      add :phone, :string

      timestamps()
    end

     create unique_index(:users, [:arti_phone])
  end
end
