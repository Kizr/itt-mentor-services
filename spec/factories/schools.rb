# == Schema Information
#
# Table name: schools
#
#  id                           :uuid             not null, primary key
#  address1                     :string
#  address2                     :string
#  address3                     :string
#  admissions_policy            :string
#  claims_service               :boolean          default(FALSE)
#  district_admin_code          :string
#  district_admin_name          :string
#  email_address                :string
#  gender                       :string
#  group                        :string
#  last_inspection_date         :date
#  maximum_age                  :integer
#  minimum_age                  :integer
#  name                         :string
#  percentage_free_school_meals :integer
#  phase                        :string
#  placements_service           :boolean          default(FALSE)
#  postcode                     :string
#  rating                       :string
#  religious_character          :string
#  school_capacity              :integer
#  send_provision               :string
#  special_classes              :string
#  telephone                    :string
#  total_boys                   :integer
#  total_girls                  :integer
#  total_pupils                 :integer
#  town                         :string
#  training_with_disabilities   :string
#  type_of_establishment        :string
#  ukprn                        :string
#  urban_or_rural               :string
#  urn                          :string           not null
#  website                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  region_id                    :uuid
#
# Indexes
#
#  index_schools_on_claims_service      (claims_service)
#  index_schools_on_placements_service  (placements_service)
#  index_schools_on_region_id           (region_id)
#  index_schools_on_urn                 (urn) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (region_id => regions.id)
#
FactoryBot.define do
  factory :school do
    association :region
    sequence(:urn) { _1 }
    name { Faker::Educator.primary_school }

    trait :claims do
      claims_service { true }
    end

    trait :placements do
      placements_service { true }
    end

    factory :claims_school,
            class: "Claims::School",
            parent: :school, traits: %i[claims]

    factory :placements_school,
            class: "Placements::School",
            parent: :school, traits: %i[placements]
  end
end
