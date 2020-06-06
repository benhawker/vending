# Vending

A Ruby 2.7.1 application that models a Vending Machine.

There is a single branch `master`.

Functional requirements:

```
Design a vending machine that behaves as follows:
- Once an item is selected and the appropriate amount of money is inserted,
the vending machine should return the correct product
- It should also return change if too much money is provided, or ask for more
money if insufficient funds have been inserted
- The machine should take an initial load of products and change. The change
will be of denominations 1p, 2p, 5p, 10p, 20p, 50p, £1, £2
- There should be a way of reloading either products or change at a later point
- The machine should keep track of the products and change that it contains.

```

- See `bin/demo` for a insight into how to use this program.

- This took ~3.5hrs.

- Comments left through the code with assumptions/consideratons.

- Specs could be more concise and DRY but provide reasonable coverage (given the time constraint).

- I have intentionally not addresssed (due to time constraints) the intial load of coins and reloading of additonal coins. See the comment above `MoneyHandler#coins_to_return` where I have explained how I would approach this.

===================

### Usage:

Allow executable permissions:

```
chmod +x bin/console
chmod +x bin/demo
```

To start a session (with the Vending Machine loaded):

```
bin/console
```


Run the specs:
```
rspec
```

===================

Example session:

```
[1] pry(main)> machine = VendingMachine.new
=> #<VendingMachine:0x00007fd7ebbb3e18
 @money_handler=#<MoneyHandler:0x00007fd7ebbb3878 @coin_slot=[]>,
 @selected_item_code=nil,
 @stock_handler=
 	....

[2] pry(main)> machine.select_item(code: 1)
Please insert some money first=> nil

[3] pry(main)> machine.insert_coin(amount: 5)
Insufficient funds to purchase this item=> nil

[4] pry(main)> machine.insert_coin(amount: 10)
Returning: 5p...with the following coins:"5p"
Sale completed! 
=> nil
```

