67272 Chess Store Project: Phase 5 Starter
===

You will need to run `bundle install` to get the needed testing gems. You can populate the development database with realistic data by running `rake db:populate`.  All passwords are 'secret' in the system for all users. The list of known users include (username, role): 

- Mark ('mark', admin)
- Alex ('tank', admin)
- Karen ('kirvine', customer)
- Ben  ('bjunker', customer)
- Israel ('imadueme', customer)
- Mark V ('mvella', customer)
- Melanie ('melfree', customer)
- Rick ('rhuang', manager)
- Becca  ('bkern', manager)
- Connor ('chanley', shipper)
- Sarah ('srf', shipper)

There are other 40 customers randomly generated in the system along with 45 schools.  The known customers should have 3-5 orders each and 20 other random customer/school combinations will also have placed orders. (Five of those orders have been placed either today or the day before and haven't been shipped yet, so shipper list will have some items to ship.)

You have been given some additional starter code, including the Cart module, as discussed in class. You may edit these modules so long as everything works as it is supposed to -- breaking working code can have serious consequences so do so carefully.

The focus this phase is not so much on the testing as it is designing the user's interactions and experience with the chess store app.
