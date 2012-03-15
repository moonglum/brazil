require "spec_helper"

describe Brazil do
  describe Brazil::Query do
    before :each do
      @query = Brazil::Query.new
    end
    
    it "should be created succesful" do
      @query.should be
    end
    
    it "should accept a from statetement" do
      @query.should respond_to(:from).with(1).argument
    end
    
    it "should raise a Runtime Error when evaluate is called without from being called" do
      expect { @query.evaluate }.to raise_error(RuntimeError, "From statement was not provided")
    end
    
    it "should raise a Runtime Error for a misformed from statement" do
      expect { @query.from 12 }.to raise_error(RuntimeError, "Misformed From Statement")
      expect { @query.from "rabble" }.to raise_error(RuntimeError, "Misformed From Statement")
    end
    
    it "should not raise a Runtime Error for a valid from statement" do
      expect { @query.from "collection c" }.to_not raise_error(RuntimeError)
    end
    
    it "should return the Query object for from in order to provide chaining" do
      @query.from("collection c").should equal(@query)
    end
    
    describe "a valid from statement has been provided" do
      before :each do
        @query.from("collection c")
      end
      
      it "should return a String when being evaluated" do
        @query.evaluate.class.should equal(String)
      end
      
      it "should return an AQL statement querying the entire collection" do
        @query.evaluate.should ==("SELECT c FROM collection c")
      end
      
      it "should raise a Runtime Error when provided with a second valid from statement" do
        expect { @query.from "collection c" }.to raise_error(RuntimeError, "From statement already provided")
      end
      
      describe "the where clause" do
        it "should add a correctly formed where statement to the AQL query" do
          @query.where("c.count > 5")
          @query.evaluate.should ==("SELECT c FROM collection c WHERE c.count > 5")
        end
        
        it "should return the Query object itself for where to provide chaining" do
          @query.where("c.count > 5").should equal(@query)
        end
        
        it "should connect multiple where statements with the logical and" do
          @query.where("c.count > 5")
          @query.where("c.count < 200")
          @query.evaluate.should ==("SELECT c FROM collection c WHERE c.count > 5 && c.count < 200")
        end
      end
      
    end
  end
end
