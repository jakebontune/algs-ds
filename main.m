//
//  main.m
//  algs-ds-objc
//
//  Created by Joseph Ayo-Vaughan on 8/11/16.
//  Copyright © 2016 Ode to Sound. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utilities/JLog.h"
#import "JVDataStructures/JVMutableSinglyLinkedList.h"
#import "JVDataStructures/JVMutableDoublyLinkedList.h"
#import "JVDataStructures/JVStack.h"
#import "JVDataStructures/JVQueue.h"
#import "JVOperations/JVParenthesesParser.h"
#import "JVOperations/JVExpressionParser.h"
#import "JVDataStructures/JVMutableDictionary.h"
#import "JVDataStructures/JVBinarySearchTree.h"
#import "JVDataStructures/JVTreeDictionarySet.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {

    	// NSLog(@"***Singly-Linked List***");
        // JVMutableSinglyLinkedList<NSNumber *> *sll = [[JVMutableSinglyLinkedList alloc] initWithObject:@22];
        // [sll print];
        // [sll addObject:@53];
        // [sll print];
        // [sll insertObject:@995 atIndex:0];
        // [sll print];
        // [sll insertObject:@194 atIndex:1];
        // [sll print];
        // [sll insertObject:@111 atIndex:3];
        // [sll print];
        // [sll insertObjectAtEnd:@44];
        // [sll print];

        // [sll removeFirstObject];
        // [sll print];
        // [sll removeObjectAtIndex:0];
        // [sll print];
        // [sll removeObjectAtIndex:3];
        // [sll print];
        // [sll removeLastObject];
        // [sll print];

        // [sll addObject:@53];
        // [sll print];
        // [sll insertObject:@995 atIndex:0];
        // [sll print];
        // [sll insertObject:@194 atIndex:1];
        // [sll print];
        // [sll insertObject:@111 atIndex:3];
        // [sll print];
        // [sll insertObjectAtEnd:@44];
        // [sll print];

        // [sll printReverse];
        // NSLog(@"Count: %lu", [sll count]);

        // NSLog(@"-----");

    	// NSLog(@"***Doubly-Linked List***");
        // JVMutableDoublyLinkedList *dll = [[JVMutableDoublyLinkedList alloc] initWithObject:@22];
        // [dll print];
        // [dll addObject:@53];
        // [dll print];
        // [dll insertObject:@995 atIndex:0];
        // [dll print];
        // [dll insertObject:@194 atIndex:1];
        // [dll print];
        // [dll insertObject:@111 atIndex:3];
        // [dll print];
        // [dll insertObjectAtEnd:@44];
        // [dll print];

        // [dll removeFirstObject];
        // [dll print];
        // [dll removeObjectAtIndex:0];
        // [dll print];
        // [dll removeObjectAtIndex:3];
        // [dll print];
        // [dll removeLastObject];
        // [dll print];

        // [dll addObject:@53];
        // [dll print];
        // [dll insertObject:@995 atIndex:0];
        // [dll print];
        // [dll insertObject:@194 atIndex:1];
        // [dll print];
        // [dll insertObject:@111 atIndex:3];
        // [dll print];
        // [dll insertObjectAtEnd:@44];
        // [dll print];

        // [dll printReverse];
        // NSLog(@"Count: %lu", [dll count]);

        // NSLog(@"-----");

        // NSLog(@"***Stack***");

        // JVStack<NSNumber *> *stack = [JVStack stackWithElement:@22];
        // [stack push:@53];
        // [stack push:@995];
        // [stack push:@194];
        // [stack push:@111];
        // [stack push:@44];

        // NSLog(@"popped: %d", ((NSNumber*)[stack pop]).intValue);
        // NSLog(@"popped: %d", ((NSNumber*)[stack pop]).intValue);
        // NSLog(@"popped: %d", ((NSNumber*)[stack pop]).intValue);
        // NSLog(@"popped: %d", ((NSNumber*)[stack pop]).intValue);
        // NSLog(@"popped: %d", ((NSNumber*)[stack pop]).intValue);
        // NSLog(@"popped: %d", ((NSNumber*)[stack pop]).intValue);
        // // NSLog(@"popped: %d", ((NSNumber*)[stack pop]).intValue);

        // NSLog(@"-----");

        // NSLog(@"***Queue***");

        // JVQueue<NSNumber *> *queue = [JVQueue queueWithElement:@22];
        // [queue enqueue:@53];
        // [queue enqueue:@995];
        // [queue enqueue:@194];
        // [queue enqueue:@111];
        // [queue enqueue:@44];

        // NSLog(@"dequeued: %d", ((NSNumber*)[queue dequeue]).intValue);
        // NSLog(@"dequeued: %d", ((NSNumber*)[queue dequeue]).intValue);
        // NSLog(@"dequeued: %d", ((NSNumber*)[queue dequeue]).intValue);
        // NSLog(@"dequeued: %d", ((NSNumber*)[queue dequeue]).intValue);
        // NSLog(@"dequeued: %d", ((NSNumber*)[queue dequeue]).intValue);
        // NSLog(@"dequeued: %d", ((NSNumber*)[queue dequeue]).intValue);

        // NSLog(@"-----");

        // NSLog(@"***Parentheses Parser***");

        // JVParenthesesParser *pp = [[JVParenthesesParser alloc] init];
        // NSMutableString *pString = [NSMutableString stringWithString:@"{()(}"];
        // NSLog(@"Expression: %@", pString);
        // [pp checkParenthesesInString:pString] == true ? NSLog(@"balanced!") : NSLog(@"unbalanced");

        //  NSLog(@"-----");

        // NSLog(@"***Expression Parser***");

        // JVExpressionParser *ep = [[JVExpressionParser alloc] init];
        // [pString setString:@"348*8%-3+"];
        // NSLog(@"Parsed postfix expression result: %ld", [ep parsePostfixExpression:pString]);

        // [pString setString:@"+-3/*4883"];
        // NSLog(@"Parsed prefix expression result: %ld", [ep parsePrefixExpression:pString]);

        // [pString setString:@"((A+B)%C-D)*E"];
        // NSLog(@"Infix to postfix: ((A+B)*C-D)*E ----> %@", [ep convertInfixToPostfix:pString]);

        // NSLog(@"-----");

        // NSLog(@"***Dictionary***");

        // JVMutableDictionary<NSString *, NSString *> *dictionary = [[JVMutableDictionary alloc] init];

        // NSLog(@"Count: %lu", [dictionary count]);

        // NSLog(@"----Add Objects----");
        // [dictionary setObject:@"Bojangles" forKey:@"name"];
        // [dictionary setObject:@"41" forKey:@"age"];
        // [dictionary setObject:@"1955 Laborea Ave" forKey:@"address"];
        // [dictionary setObject:@"Sally Cho" forKey:@"spouse"];

        // NSLog(@"Count: %lu", [dictionary count]);

        // NSLog(@"----Object For Key----");
        // NSLog(@"%@", [dictionary objectForKey:@"name"]);
        // NSLog(@"%@", [dictionary objectForKey:@"age"]);
        // NSLog(@"%@", [dictionary objectForKey:@"address"]);
        // NSLog(@"%@", [dictionary objectForKey:@"spouse"]);

        // NSLog(@"----Enumeration----");
        // NSEnumerator *enumerator = [dictionary keyEnumerator];
        // NSString *key; int i = 0;
        // while(key = [enumerator nextObject]) {
        //     NSLog(@"%@ %d", key, ++i);
        // }

        // NSLog(@"----Remove Objects----");
        // [dictionary removeObjectForKey:@"age"];
        // [dictionary removeObjectForKey:@"spouse"];

        // NSLog(@"Count: %lu", [dictionary count]);

        // NSLog(@"----Object For Key----");
        // NSLog(@"%@", [dictionary objectForKey:@"name"]);
        // NSLog(@"%@", [dictionary objectForKey:@"age"]);
        // NSLog(@"%@", [dictionary objectForKey:@"address"]);
        // NSLog(@"%@", [dictionary objectForKey:@"spouse"]);

        // enumerator = [dictionary keyEnumerator];
        // NSLog(@"----Enumeration----");
        // while(key = [enumerator nextObject]) {
        //     NSLog(@"%@", key);
        // }

        // NSLog(@"-----");

        // NSLog(@"***Binary Search Tree (BST)***");
        // JVBinarySearchTree<NSNumber *> *tree = [JVBinarySearchTree tree];
        // NSEnumerator *treeEnumerator;

        // NSLog(@"----Adding Objects----");
        // [tree addObjectsFromArray:@[ @44, @21, @76, @33, @52, @96 ]];

        // NSLog(@"----Breadth-First Traversal----");
        // treeEnumerator = [tree enumeratorUsingTraversalOrder:JVBinarySearchTraversalOrderBreadthFirst];
        // for(NSNumber *number in treeEnumerator) JLog(@"%lu ", [number integerValue]);
        // JLog(@"\n");
        // JLog(@"count: %lu\n", [tree count]);

        // NSLog(@"----Removing Objects----");
        // [tree removeObjectsInArray:@[ @44, @17, @96 ]];

        // NSLog(@"----Breadth-First Traversal----");
        // treeEnumerator = [tree enumeratorUsingTraversalOrder:JVBinarySearchTraversalOrderBreadthFirst];
        // for(NSNumber *number in treeEnumerator) JLog(@"%lu ", [number integerValue]);
        // JLog(@"\n");
        // JLog(@"count: %lu\n", [tree count]);

        // NSLog(@"----Root Object----");
        // NSLog(@"%lu", [tree rootObject].integerValue);

        // NSLog(@"----Adding Objects----");
        // [tree addObjectsFromArray:@[ @44, @21, @76, @33, @52, @96 ]];

        // NSLog(@"----Breadth-First Traversal----");
        // treeEnumerator = [tree enumeratorUsingTraversalOrder:JVBinarySearchTraversalOrderBreadthFirst];
        // for(NSNumber *number in treeEnumerator) JLog(@"%lu ", [number integerValue]);
        // JLog(@"\n");
        // JLog(@"count: %lu\n", [tree count]);

        // NSLog(@"----Preorder Traversal----");
        // treeEnumerator = [tree enumeratorUsingTraversalOrder:JVBinarySearchTraversalOrderPreorder];
        // for(NSNumber *number in treeEnumerator) JLog(@"%lu ", [number integerValue]);
        // JLog(@"\n");
        // JLog(@"count: %lu\n", [tree count]);

        // NSLog(@"----InOrder Traversal----");
        // treeEnumerator = [tree enumeratorUsingTraversalOrder:JVBinarySearchTraversalOrderInOrder];
        // for(NSNumber *number in treeEnumerator) JLog(@"%lu ", [number integerValue]);
        // JLog(@"\n");
        // JLog(@"count: %lu\n", [tree count]);

        // NSLog(@"----PostOrder Traversal----");
        // treeEnumerator = [tree enumeratorUsingTraversalOrder:JVBinarySearchTraversalOrderPostOrder];
        // for(NSNumber *number in treeEnumerator) JLog(@"%lu ", [number integerValue]);
        // JLog(@"\n");
        // JLog(@"count: %lu\n", [tree count]);

        // NSLog(@"----Root Object----");
        // NSLog(@"%lu", [tree rootObject].integerValue);

        // NSLog(@"----Minimum Object----");
        // NSLog(@"%lu", [tree minimumObject].integerValue);

        // NSLog(@"----Maximum Object----");
        // NSLog(@"%lu", [tree maximumObject].integerValue);

        // NSLog(@"-----");

        // NSLog(@"***Tree Dictionary Set***");
        // JVTreeDictionarySet<NSNumber *, NSString *> *treeDictionarySet;
        // NSDictionary *tdsDictionary = @{
        //     @1 : @"1",
        //     @2 : @"2",
        //     @3 : @"3",
        //     @4 : @"4",
        //     @5 : @"5"
        // };

        // NSLog(@"----Adding Objects----");
        // treeDictionarySet = [JVTreeDictionarySet treeDictionarySetWithDictionary:tdsDictionary];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"----Adding Objects----");
        // tdsDictionary = @{
        //     @6 : @"6",
        //     @7 : @"7",
        //     @8 : @"8",
        //     @9 : @"9",
        //     @10 : @"10"
        // };
        // [treeDictionarySet addEntriesFromDictionary:tdsDictionary];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"----Removing Objects----");
        // NSArray *tdsArray = @[@3, @6, @9];
        // [treeDictionarySet removeObjectsForKeys:tdsArray];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"----Joining Objects----");
        // [treeDictionarySet joinObjectForKey:@2 andObjectForKey:@7];
        // [treeDictionarySet joinObjectForKey:@5 andObjectForKey:@7];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"----Finding the Root of Objects----");
        // NSNumber *tdsKey = [treeDictionarySet rootKeyOfObjectForKey:@7];
        // NSLog(@"Root of 7 is %lu", tdsKey.integerValue);

        // tdsKey = [treeDictionarySet rootKeyOfObjectForKey:@2];
        // NSLog(@"Root of 2 is %lu", tdsKey.integerValue);

        // tdsKey = [treeDictionarySet rootKeyOfObjectForKey:@5];
        // NSLog(@"Root of 5 is %lu", tdsKey.integerValue);

        // tdsKey = [treeDictionarySet rootKeyOfObjectForKey:@1];
        // NSLog(@"Root of 1 is %lu", tdsKey.integerValue);

        // NSLog(@"----Adding Objects----");
        // tdsDictionary = @{
        //     @11 : @"11",
        //     @12 : @"12",
        //     @13 : @"13",
        //     @14 : @"14",
        //     @10 : @"TEN"
        // };
        // [treeDictionarySet addEntriesFromDictionary:tdsDictionary];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"Overall count: %lu, Component count: %lu", [treeDictionarySet count], [treeDictionarySet componentCount]);

        // NSLog(@"----Removing Objects----");
        // tdsArray = @[@14, @1, @5];
        // [treeDictionarySet removeObjectsForKeys:tdsArray];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"Overall count: %lu, Component count: %lu", [treeDictionarySet count], [treeDictionarySet componentCount]);

        // NSLog(@"----Adding Objects----");
        // for(NSUInteger i = 21; i < 101; ++i) {
        //     [treeDictionarySet setObject:@(i).stringValue forKey:@(i)];
        // }

        // NSLog(@"----Joining Objects----");
        // [treeDictionarySet joinObjectForKey:@2 andObjectForKey:@7];
        // [treeDictionarySet joinObjectForKey:@5 andObjectForKey:@7];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"Overall count: %lu, Component count: %lu", [treeDictionarySet count], [treeDictionarySet componentCount]);

        // NSLog(@"----Disjoining Objects----");
        // [treeDictionarySet disjoinObjectForKey:@2 andObjectForKey:@7];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"Overall count: %lu, Component count: %lu", [treeDictionarySet count], [treeDictionarySet componentCount]);

        // NSLog(@"----Joining Array of Objects----");
        // NSMutableArray *tdsArray1 = [NSMutableArray array];
        // NSMutableArray *tdsArray2 = [NSMutableArray array];
        // for(NSUInteger i = 21; i < 41; ++i) {
        //     [tdsArray1 addObject:@(i)];
        // }

        // for(NSUInteger i = 41; i < 61; ++i) {
        //     [tdsArray2 addObject:@(i)];
        // }

        // [treeDictionarySet joinObjectsForKeys:@[@21] andObjectsForKeys:tdsArray2 parallely:NO];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"Overall count: %lu, Component count: %lu", [treeDictionarySet count], [treeDictionarySet componentCount]);

        // NSLog(@"----Disjoining Array of Objects----");
        // [treeDictionarySet disjoinObjectsForKeys:@[@21] andObjectsForKeys:tdsArray2 parallely:NO];

        // NSLog(@"----TDS Enumeration----");
        // [treeDictionarySet enumerateKeysAndObjectsUsingBlock:^(NSNumber *key, NSString *obj, BOOL isComponentRoot, BOOL *stop) {
        //     NSLog(@"Key: %lu, \tValue: %@, \tisComponentRoot: %d, \tRoot: %@, \tparent: %lu, \tnumDescendents: %lu", key.integerValue, obj, isComponentRoot, [treeDictionarySet rootKeyOfObjectForKey:key], ((NSNumber *)[treeDictionarySet parentKeyOfObjectForKey:key]).integerValue, [treeDictionarySet numberOfDescendantsOfObjectForKey:key]);
        // }];

        // NSLog(@"Overall count: %lu, Component count: %lu", [treeDictionarySet count], [treeDictionarySet componentCount]);
    }

    return 0;
}
