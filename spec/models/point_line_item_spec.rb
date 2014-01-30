require 'spec_helper'

describe PointLineItem do
	it { should respond_to(:points)}
	it { should respond_to(:source)}
	it { should respond_to(:created_at)}
	it { should respond_to(:expired)}

	it { should belong_to(:user)}

	it { should have_db_index(:user_id)}
	it { should have_db_index(:created_at)}
  
end
