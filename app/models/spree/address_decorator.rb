# look for state name ignoring case
module Spree
  Address.class_eval do

    before_validation :sanitize_state_name

    private

    def sanitize_state_name
      return unless self.state_name

      state_found = State.where('name ILIKE :s_name OR abbr ILIKE :s_name', s_name: self.state_name).first.try(:name)
      self.state_name = state_found if state_found
    end
  end
end
