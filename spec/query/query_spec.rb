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
      
      describe "the left join clauses" do
        it "should refuse join clauses without the on parameter" do
          expect { @query.left_join "collection d" }.to raise_error(ArgumentError)
          expect { @query.left_join "collection d", 21 }.to raise_error(RuntimeError, "on statement missing")
          expect { @query.left_join "collection d", :for => "c.id = d.id" }.to raise_error(RuntimeError, "on statement missing")
        end
        
        it "should add a left join to the query" do
          @query.left_join "collection d", :on => "c.id == d.id"
          @query.evaluate.should ==("SELECT c FROM collection c LEFT JOIN collection d ON c.id == d.id")
        end
        
        it "should combine multiple joins in a row" do
          @query.left_join "collection d", :on => "c.id == d.id"
          @query.left_join "collection e", :on => "d.id == e.id"
          @query.evaluate.should ==("SELECT c FROM collection c LEFT JOIN collection d ON c.id == d.id LEFT JOIN collection e ON d.id == e.id")
        end
        
        it "should return the Query object itself for where to provide chaining" do
          @query.left_join("collection d", :on => "c.id == d.id").should equal(@query)
        end
      end
      
      describe "the right join clauses" do
        it "should refuse join clauses without the on parameter" do
          expect { @query.right_join "collection d" }.to raise_error(ArgumentError)
          expect { @query.right_join "collection d", 21 }.to raise_error(RuntimeError, "on statement missing")
          expect { @query.right_join "collection d", :for => "c.id = d.id" }.to raise_error(RuntimeError, "on statement missing")
        end
        
        it "should add a right join to the query" do
          @query.right_join "collection d", :on => "c.id == d.id"
          @query.evaluate.should ==("SELECT c FROM collection c RIGHT JOIN collection d ON c.id == d.id")
        end
        
        it "should combine multiple joins in a row" do
          @query.right_join "collection d", :on => "c.id == d.id"
          @query.right_join "collection e", :on => "d.id == e.id"
          @query.evaluate.should ==("SELECT c FROM collection c RIGHT JOIN collection d ON c.id == d.id RIGHT JOIN collection e ON d.id == e.id")
        end
        
        it "should return the Query object itself for where to provide chaining" do
          @query.right_join("collection d", :on => "c.id == d.id").should equal(@query)
        end
      end
      
      describe "the inner join clauses" do
        it "should refuse join clauses without the on parameter" do
          expect { @query.inner_join "collection d" }.to raise_error(ArgumentError)
          expect { @query.inner_join "collection d", 21 }.to raise_error(RuntimeError, "on statement missing")
          expect { @query.inner_join "collection d", :for => "c.id = d.id" }.to raise_error(RuntimeError, "on statement missing")
        end
        
        it "should add a right join to the query" do
          @query.inner_join "collection d", :on => "c.id == d.id"
          @query.evaluate.should ==("SELECT c FROM collection c INNER JOIN collection d ON c.id == d.id")
        end
        
        it "should combine multiple joins in a row" do
          @query.inner_join "collection d", :on => "c.id == d.id"
          @query.inner_join "collection e", :on => "d.id == e.id"
          @query.evaluate.should ==("SELECT c FROM collection c INNER JOIN collection d ON c.id == d.id INNER JOIN collection e ON d.id == e.id")
        end
        
        it "should return the Query object itself for where to provide chaining" do
          @query.inner_join("collection d", :on => "c.id == d.id").should equal(@query)
        end
      end
      
      describe "the order clause" do
        it "should add the order clause to the query" do
          @query.order "c.age"
          @query.evaluate.should ==("SELECT c FROM collection c ORDER BY c.age")
        end
        
        it "should raise a Runtime Error if the order clause was used before" do
          @query.order "c.age"
          expect { @query.order "d.age" }.to raise_error(RuntimeError, "order statement already added")
        end
        
        it "should add a list of order clauses to the query" do
          @query.order "c.age ASC", "c.name"
          @query.evaluate.should ==("SELECT c FROM collection c ORDER BY c.age ASC, c.name")
        end
        
        it "should return the Query object itself for order by to provide chaining"
      end
      
      describe "the limit clause" do
        it "should raise a Runtime Error if neither a maximum nor from and to are declared" do
          expect { @query.limit socks: 5 }.to raise_error(RuntimeError, "neither maximum nor from and to are declared")
        end
        
        it "should add the order clause with a maximum to the query" do
          @query.limit maximum: 5
          @query.evaluate.should ==("SELECT c FROM collection c LIMIT 5")
        end
        
        it "should raise a Runtime Error if a maximum and a from or a to are declared" do
          expect { @query.limit maximum: 5, from: 1 }.to raise_error(RuntimeError, "either use maximum or from and to")
          expect { @query.limit maximum: 5, to: 5 }.to raise_error(RuntimeError, "either use maximum or from and to")
        end
        
        it "should add the order clause with a to and from to the query" do
          @query.limit from: 5, to: 10
          @query.evaluate.should ==("SELECT c FROM collection c LIMIT 5, 10")
        end
        
        it "should raise a Runtime Error if the limit clause was used before" do
          @query.limit maximum: 5
          expect { @query.limit maximum: 10 }.to raise_error(RuntimeError, "limit statement already added")
        end
        
        it "should return the Query object itself for limit to provide chaining"
      end
      
      describe "find by geo coordinate" do
        it "should raise a Runtime Error if the reference point is missing" do
          expect { @query.find_by_geocoordinates attributes: ["c.x", "c.y"], maximum: 5}.to raise_error(RuntimeError, "no reference point was assigned")
        end
        
        it "should raise a Runtime Error if neither a radius nor a maximum is given" do
          expect { @query.find_by_geocoordinates attributes: ["c.x", "c.y"], reference: [37.331953, -122.029669]}.to raise_error(RuntimeError, "neither a radius nor a maximum was given")
        end
        
        it "should add a WITHIN statement to the query with explicit attributes" do
          @query.find_by_geocoordinates attributes: ["c.x", "c.y"], reference: [37.331953, -122.029669], radius: 50
          @query.evaluate.should ==("SELECT c FROM collection c WITHIN [c.x, c.y], [37.331953, -122.029669], 50")
        end
        
        it "should add a WITHIN statement to the query with explicit attributes" do
          @query.find_by_geocoordinates attributes: ["c.x", "c.y"], reference: [37.331953, -122.029669], maximum: 5
          @query.evaluate.should ==("SELECT c FROM collection c NEAR [c.x, c.y], [37.331953, -122.029669], 5")
        end
        
        it "should raise a Runtime Error if a radius and a maximum is given" do
          expect {@query.find_by_geocoordinates attributes: ["c.x", "c.y"], reference: [37.331953, -122.029669], maximum: 5, radius: 50}.to raise_error(RuntimeError, "you can't add maximum and radius at once")
        end
        
        it "should add the default value for the WITHIN statement if no explicit attributes are given" do
          @query.find_by_geocoordinates reference: [37.331953, -122.029669], radius: 50
          @query.evaluate.should ==("SELECT c FROM collection c WITHIN [c.x, c.y], [37.331953, -122.029669], 50")
        end
        
        it "should return the Query object itself for geo coordinates to provide chaining"
      end
    end
  end
end
