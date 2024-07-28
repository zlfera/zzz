defmodule Zlfera.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Inspect,
           except: [
             :address,
             :bank_id,
             :busi_type,
             :cert_code,
             :cust_id,
             :deposit_bank,
             :email,
             :fax,
             :manage_type,
             :phone
           ]}
  schema "users" do
    field :address, :string
    field :arti_person, :string
    field :arti_phone, :string
    field :bank_id, :string
    field :busi_name, :string
    field :busi_type, :string
    field :cert_code, :string
    field :cust_id, :string
    field :deposit_bank, :string
    field :email, :string
    field :fax, :string
    field :link_mane, :string
    field :link_phone, :string
    field :manage_type, :string
    field :phone, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [
      :address,
      :arti_person,
      :arti_phone,
      :bank_id,
      :busi_name,
      :busi_type,
      :cert_code,
      :cust_id,
      :deposit_bank,
      :email,
      :fax,
      :link_mane,
      :link_phone,
      :manage_type,
      :phone
    ])
    |> validate_required([
      :address,
      :arti_person,
      :arti_phone,
      :bank_id,
      :busi_name,
      :busi_type,
      :cert_code,
      :cust_id,
      :deposit_bank,
      :email,
      :fax,
      :link_mane,
      :link_phone,
      :manage_type,
      :phone
    ])
    |> unique_constraint(:arti_phone)
  end
end
