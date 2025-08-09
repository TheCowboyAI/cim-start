# Event Storming Guide for Domain Discovery

Copyright 2025 - Cowboy AI, LLC

## 🎯 What is Event Storming?

Event Storming is a workshop technique to quickly discover your domain by focusing on **what happens** in your business. In 1-2 hours, you'll have a complete domain model!

## 🏃 Quick Version (30 minutes, solo)

### Materials Needed
- Sticky notes (or this digital template)
- Different colors for different concepts
- A wall or board (or this document)

### Color Legend
- 🟧 **Orange** = Domain Events (things that happened)
- 🟦 **Blue** = Commands (user actions)  
- 🟨 **Yellow** = Aggregates (main entities)
- 🟪 **Purple** = Policies (automated rules)
- 🟥 **Red** = Problems/Questions
- 🟩 **Green** = External Systems

## 📋 Step-by-Step Process

### Phase 1: Chaotic Exploration (10 minutes)
**Goal: Get all events out without thinking too hard**

Write down everything that happens in your business:
```
🟧 Customer Registered
🟧 Order Placed
🟧 Payment Failed
🟧 Item Shipped
🟧 Inventory Depleted
🟧 Price Changed
🟧 Discount Applied
🟧 Return Requested
```

**Your Events:**
```
🟧 ________________
🟧 ________________
🟧 ________________
🟧 ________________
🟧 ________________
🟧 ________________
🟧 ________________
🟧 ________________
```

### Phase 2: Timeline Ordering (5 minutes)
**Goal: Put events in chronological order**

Arrange your events in time sequence:
```
Timeline: [Start] → 🟧 → 🟧 → 🟧 → 🟧 → [End]
```

**Your Timeline:**
```
[Start] → ________________ → ________________ → ________________ → [End]
```

### Phase 3: Add Commands (5 minutes)
**Goal: What triggers each event?**

For each event, add the command that causes it:
```
🟦 Register Customer → 🟧 Customer Registered
🟦 Place Order → 🟧 Order Placed
🟦 Process Payment → 🟧 Payment Processed OR 🟧 Payment Failed
```

**Your Commands:**
```
🟦 ________________ → 🟧 ________________
🟦 ________________ → 🟧 ________________
🟦 ________________ → 🟧 ________________
```

### Phase 4: Find Aggregates (5 minutes)
**Goal: Group related events around entities**

What "thing" do events happen to?
```
🟨 Customer
  └─ 🟧 Customer Registered
  └─ 🟧 Email Verified
  └─ 🟧 Profile Updated

🟨 Order
  └─ 🟧 Order Placed
  └─ 🟧 Order Confirmed
  └─ 🟧 Order Shipped
```

**Your Aggregates:**
```
🟨 ________________
  └─ 🟧 ________________
  └─ 🟧 ________________

🟨 ________________
  └─ 🟧 ________________
  └─ 🟧 ________________
```

### Phase 5: Identify Policies (5 minutes)
**Goal: Find automated reactions**

When X happens, Y automatically happens:
```
🟪 When Order Placed → Check Inventory
🟪 When Payment Received → Ship Order
🟪 When Inventory Low → Reorder Stock
```

**Your Policies:**
```
🟪 When ________________ → ________________
🟪 When ________________ → ________________
🟪 When ________________ → ________________
```

## 🎨 Full Workshop Version (1-2 hours, team)

### Participants
- Domain Expert (knows the business)
- Developers (will build it)
- Product Owner (owns requirements)
- Users (optional but valuable)

### Extended Process

#### 1. Big Picture (20 min)
Everyone writes events on orange stickies. No discussion, just write!

#### 2. Enforce Timeline (15 min)
Group arranges events chronologically together.

#### 3. Reverse Narrative (15 min)
Walk backwards through timeline, adding missing events.

#### 4. Find Pivotal Events (10 min)
Mark events that change the flow significantly.

#### 5. Add Commands & Actors (15 min)
Who does what to trigger events?

#### 6. Define Aggregates (15 min)
Group events around business entities.

#### 7. Draw Boundaries (15 min)
Separate into bounded contexts.

#### 8. Identify Policies (10 min)
Find all automatic reactions.

#### 9. Add External Systems (10 min)
What outside systems are involved?

#### 10. Model Data (15 min)
What information does each event carry?

## 📝 Digital Template

### Your Domain Events
Copy and fill this template:

```yaml
domain: your-domain-name
discovered_date: YYYY-MM-DD
participants: [names]

events:
  - id: E001
    name: 
    description:
    triggered_by_command:
    aggregate:
    data_needed:
      - 
      - 
    
  - id: E002
    name:
    description:
    triggered_by_command:
    aggregate:
    data_needed:
      -
      -

commands:
  - id: C001
    name:
    actor:
    produces_events: [E001]
    
  - id: C002
    name:
    actor:
    produces_events: [E002]

aggregates:
  - id: A001
    name:
    owns_events: [E001, E002]
    key_properties:
      -
      -

policies:
  - id: P001
    when_event: E001
    then_action:
    produces_events: []

external_systems:
  - name:
    integrates_with_events: []

bounded_contexts:
  - name:
    contains_aggregates: []
    owns_events: []
```

## 🚀 After Event Storming

You now have:
1. **Complete event list** - All things that happen
2. **Command model** - How users interact
3. **Aggregate boundaries** - Your main entities
4. **Process policies** - Business rules
5. **Integration points** - External systems

### Next Steps:
1. **Validate** with domain experts
2. **Prioritize** which events to implement first
3. **Design** your event schemas
4. **Build** aggregates and command handlers
5. **Test** with real scenarios

## 💡 Tips for Success

### DO:
- ✅ Use past tense for events (happened)
- ✅ Use imperative for commands (do this)
- ✅ Keep events business-focused
- ✅ Question everything - use red stickies
- ✅ Include failure events (Payment Failed)

### DON'T:
- ❌ Get stuck on technical details
- ❌ Design the database
- ❌ Argue about names (note and move on)
- ❌ Skip events because they're "obvious"
- ❌ Mix commands and events

## 🎯 Example: E-Commerce Domain

```
Timeline:
🟦 Browse Catalog
  ↓
🟦 Add to Cart → 🟧 Item Added to Cart
  ↓
🟦 Checkout → 🟧 Checkout Started
  ↓
🟦 Enter Payment → 🟧 Payment Method Added
  ↓
🟦 Place Order → 🟧 Order Placed
  ↓
🟪 [Policy: When Order Placed → Reserve Inventory]
  ↓
🟧 Inventory Reserved
  ↓
🟦 Process Payment → 🟧 Payment Processed
  ↓
🟪 [Policy: When Payment Processed → Ship Order]
  ↓
🟧 Shipment Created
  ↓
🟩 [External: Shipping Provider]
  ↓
🟧 Order Shipped
  ↓
🟧 Order Delivered
```

## 🤔 Common Questions

**Q: How many events are enough?**
A: Start with 20-50 for a medium domain. You'll discover more as you build.

**Q: What if we disagree on event names?**
A: Note both options and move on. You can refactor later.

**Q: Should technical events be included?**
A: No, focus on business events. "Database Updated" is not a domain event.

**Q: How detailed should events be?**
A: Enough to understand what happened. Details go in the event data.

**Q: Can events trigger other events?**
A: Not directly. Events trigger policies, policies trigger commands, commands create events.

## 📚 Learn More

- [EventStorming Book](https://www.eventstorming.com/)
- [Domain-Driven Design](https://domainlanguage.com/ddd/)
- [Event Sourcing Patterns](https://martinfowler.com/eaaDev/EventSourcing.html)

## Ready to Start?

1. Grab your team (or go solo)
2. Set aside 1-2 hours
3. Follow this guide
4. Build your domain!

Remember: The goal is discovery, not perfection. You can always refine later!