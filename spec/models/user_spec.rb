require 'spec_helper'


describe User do
	
	it { should respond_to(:name)}
	it { should validate_presence_of(:name)}
	it { should have_many(:point_line_items)}


	
	
end