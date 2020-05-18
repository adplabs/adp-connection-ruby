module Adp
  module Product
    module DTO
      class Userinfo
        attr_accessor :sub
        attr_accessor :organizationOID
        attr_accessor :associateOID
        attr_accessor :givenName
        attr_accessor :familyName
        attr_accessor :name
        attr_accessor :email
        attr_accessor :picture

        # @param [Object] json_data
        def initialize(json_data)

          self.sub = json_data["sub"]
          self.organizationOID = json_data["organizationOID"]
          self.associateOID = json_data["associateOID"]
          self.givenName = json_data["given_name"]
          self.familyName = json_data["family_name"]
          self.name = json_data["name"]
          self.email = json_data["email"]
          self.picture = json_data["picture"]
        end
      end
    end
  end
end
