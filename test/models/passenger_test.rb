require "test_helper"

describe Passenger do
  let (:new_passenger) {
    Passenger.new(name: "Kari", phone_num: "111-111-1211")
  }
  it "can be instantiated" do
    # Assert
    expect(new_passenger.valid?).must_equal true
  end
  
  it "will have the required fields" do
    # Arrange
    new_passenger.save
    passenger = Passenger.first
    [:name, :phone_num].each do |field|
      
      # Assert
      expect(passenger).must_respond_to field
    end
  end
  
  describe "relationships" do
    it "can have many trips" do
      # Arrange
      new_passenger.save
      passenger = Passenger.first
      
      driver = Driver.create(
        name: "Sarah",
        vin: "848485859",
        car_make: "Ford",
        car_model: "Escape",
        active: false
      )
      
      trip_1 = Trip.create(
        date: "10-09-2019",
        rating: 3,
        cost: 2040,
        passenger_id: passenger.id,
        driver_id: driver.id
      )
      
      trip_2 = Trip.create(
        date: "10-19-2019",
        rating: 4,
        cost: 1140,
        passenger_id: passenger.id,
        driver_id: driver.id
      )
      
      # Assert
      expect(passenger.trips.count).must_be :>, 0
      passenger.trips.each do |trip|
        expect(trip).must_be_instance_of Trip
      end
    end
  end
  
  describe "validations" do
    it "must have a name" do
      # Arrange
      new_passenger.name = nil
      
      # Assert
      expect(new_passenger.valid?).must_equal false
      expect(new_passenger.errors.messages).must_include :name
      expect(new_passenger.errors.messages[:name]).must_equal ["can't be blank"]
    end
    
    it "must have a phone number" do
      # Arrange
      new_passenger.phone_num = nil
      
      # Assert
      expect(new_passenger.valid?).must_equal false
      expect(new_passenger.errors.messages).must_include :phone_num
      expect(new_passenger.errors.messages[:phone_num]).must_equal ["can't be blank"]
    end
  end
  
  # Tests for methods you create should go here
  describe "custom methods" do
    describe "request a ride" do
      before do
        Driver.create(
          name: "Shakira Stamm2",
          vin: "12345"
        )
      end
      
      it "can create data for a trip for a passenger" do
        Driver.destroy_all
        new_passenger.save
        
        driver = Driver.create(
          name: "Sarah",
          vin: "848485859",
          car_make: "Ford",
          car_model: "Escape",
          active: false
        )
        
        trip_data = {
          trip: {
            date: Date.today,
            rating: nil,
            cost: rand(165..4000),
            passenger_id: new_passenger.id,
            driver_id: driver.id 
          }
        }
        
        requested_trip_data = new_passenger.request_trip
        
        expect(requested_trip_data).must_be_instance_of Hash
        expect(requested_trip_data[:trip][:date]).must_equal trip_data[:trip][:date]
        expect(requested_trip_data[:trip][:rating]).must_equal trip_data[:trip][:rating]
        expect(requested_trip_data[:trip][:passenger_id]).must_equal trip_data[:trip][:passenger_id]
        p requested_trip_data
        
        expect(requested_trip_data[:trip][:driver_id]).must_equal trip_data[:trip][:driver_id]
      end
      
      it "return nil if there's no driver available" do
        expect(Driver.count).must_equal 1
        Driver.first.update(active: true)
        new_passenger.save
        
        assert_nil(new_passenger.request_trip)
      end
    end
    
    describe "complete trip" do
      # Your code here
    end
    
    describe "total expense to dollars" do
      before do
        new_passenger.save
        @passenger = Passenger.first
        
        driver = Driver.create(
          name: "Sarah",
          vin: "848485859",
          car_make: "Ford",
          car_model: "Escape",
          active: true
        )
        
        trip_1 = Trip.create(
          date: "10-09-2019",
          rating: 3,
          cost: 2040,
          passenger_id: @passenger.id,
          driver_id: driver.id
        )
        
        trip_2 = Trip.create(
          date: "10-19-2019",
          rating: 4,
          cost: 1140,
          passenger_id: @passenger.id,
          driver_id: driver.id
        )
      end
      
      it "can calculate the correct amount of total expense for a passenger" do
        total_expense = @passenger.trips.map{|trip| trip.cost }.sum
        expect(@passenger.total_expense_to_dollars).must_equal total_expense / 100.0
      end
    end
    # You may have additional methods to test here
  end
end
