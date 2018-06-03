class UserSerializer < ActiveModel::Serializer
  attributes %i[id uid name email deleted]
end
