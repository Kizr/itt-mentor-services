require "rails_helper"

RSpec.describe "Placements / Support / Providers / Support User adds a Provider", type: :system, js: true, service: :placements do
  let(:provider) { create(:provider, name: "Provider 1") }

  before do
    given_i_sign_in_as_colin
    provider
  end

  after { Capybara.app_host = nil }

  scenario "Colin adds a new Provider", js: true, retry: 3 do
    when_i_visit_the_add_provider_page
    then_i_see_support_navigation_with_organisation_selected
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_continue
    then_i_see_the_check_details_page_for_provider("Provider 1")
    when_i_click_add_organisation
    then_i_return_to_support_organisations_index
    and_a_provider_code_is_listed(code: "Provider 1")
    and_i_see_success_message
  end

  scenario "Colin adds a Provider which already exists", js: true, retry: 3 do
    given_a_provider_already_as_already_been_onboarded
    when_i_visit_the_add_provider_page
    then_i_see_support_navigation_with_organisation_selected
    and_i_enter_a_provider_named("Provider 1")
    then_i_see_a_dropdown_item_for("Provider 1")
    when_i_click_the_dropdown_item_for("Provider 1")
    and_i_click_continue
    then_i_see_an_error("Provider 1 has already been added. Try another provider")
  end

  scenario "Colin submits the search form without selecting a provider", js: true, retry: 3 do
    when_i_visit_the_add_provider_page
    then_i_see_support_navigation_with_organisation_selected
    and_i_click_continue
    then_i_see_an_error("Enter a provider name, UKPRN, URN or postcode")
  end

  scenario "Colin reconsiders onboarding a provider", js: true, retry: 3 do
    given_i_have_completed_the_form_to_onboard(provider:)
    when_i_click_back
    then_i_see_the_search_input_pre_filled_with("Provider 1")
    and_i_click_continue
    then_i_see_the_check_details_page_for_provider("Provider 1")
  end

  private

  def and_there_is_an_existing_user_for(user_name)
    user = create(:placements_support_user, user_name.downcase.to_sym)
    user_exists_in_dfe_sign_in(user:)
  end

  def and_i_visit_the_sign_in_page
    visit sign_in_path
  end

  def and_i_click_sign_in
    click_on "Sign in using DfE Sign In"
  end

  def when_i_visit_the_add_provider_page
    visit new_placements_support_provider_path
  end

  def then_i_see_support_navigation_with_organisation_selected
    within(".app-primary-navigation__nav") do
      expect(page).to have_link "Organisations", current: "page"
      expect(page).to have_link "Users", current: "false"
    end
  end

  def given_i_sign_in_as_colin
    and_there_is_an_existing_user_for("Colin")
    and_i_visit_the_sign_in_page
    and_i_click_sign_in
  end

  def and_i_enter_a_provider_named(provider_name)
    fill_in "provider-id-field", with: provider_name
  end

  def then_i_see_a_dropdown_item_for(provider_name)
    expect(page).to have_css(".autocomplete__option", text: provider_name)
  end

  def when_i_click_the_dropdown_item_for(provider_name)
    page.find(".autocomplete__option", text: provider_name).click
  end

  def and_i_click_continue
    click_on "Continue"
  end

  def when_i_click_back
    click_on "Back"
  end

  def then_i_see_the_check_details_page_for_provider(provider_name)
    expect(page).to have_css(".govuk-caption-l", text: "Add organisation")
    expect(page).to have_content("Check your answers")
    org_name_row = page.all(".govuk-summary-list__row")[0]
    expect(org_name_row).to have_content(provider_name)
  end

  def when_i_click_add_organisation
    click_on "Add organisation"
  end

  def then_i_return_to_support_organisations_index
    expect(page).to have_content("Organisations")
  end

  def given_a_provider_already_as_already_been_onboarded
    provider.update!(placements_service: true)
  end

  def then_i_see_an_error(error_message)
    # Error summary
    expect(page.find(".govuk-error-summary")).to have_content(
      "There is a problem",
    )
    expect(page.find(".govuk-error-summary")).to have_content(error_message)
    # Error above input
    expect(page.find(".govuk-error-message")).to have_content(error_message)
  end

  def and_a_provider_code_is_listed(code:)
    expect(page).to have_content(code)
  end

  def and_i_see_success_message
    expect(page).to have_content "Organisation added"
  end

  def given_i_have_completed_the_form_to_onboard(provider:)
    params = { provider: { id: provider.id, name: provider.name } }
    visit check_placements_support_providers_path(params)
  end

  def then_i_see_the_search_input_pre_filled_with(provider_name)
    within(".autocomplete__wrapper") do
      expect(page.find("#provider-id-field").value).to eq(provider_name)
    end
  end
end
