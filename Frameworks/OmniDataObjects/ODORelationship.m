// Copyright 2008 Omni Development, Inc.  All rights reserved.
//
// This software may only be used and reproduced according to the
// terms in the file OmniSourceLicense.html, which should be
// distributed with this project and can also be found at
// <http://www.omnigroup.com/developer/sourcecode/sourcelicense/>.

#import <OmniDataObjects/ODORelationship.h>

#import "ODOProperty-Internal.h"

#import <OmniDataObjects/ODOModel-Creation.h>
#import <OmniDataObjects/ODOEntity.h>
#import <OmniDataObjects/ODOModel.h>

RCS_ID("$Id$")

@implementation ODORelationship

- (void)dealloc;
{
    [_destinationEntity release];
    [_inverseRelationship release];
    [super dealloc];
}

- (BOOL)isToMany;
{
    return ODOPropertyFlags(self).toMany;
}

- (ODOEntity *)destinationEntity;
{
    OBPRECONDITION([_destinationEntity isKindOfClass:[ODOEntity class]]);
    return _destinationEntity;
}

- (ODORelationship *)inverseRelationship;
{
    OBPRECONDITION([_inverseRelationship isKindOfClass:[ODORelationship class]]);
    return _inverseRelationship;
}

- (ODORelationshipDeleteRule)deleteRule;
{
    return _deleteRule;
}

#pragma mark -
#pragma mark Debugging

#ifdef DEBUG
- (NSString *)shortDescription;
{
    return [NSString stringWithFormat:@"<%@:%p %@.%@ %@ %@--%@ %@ %@.%@",
            NSStringFromClass([self class]), self,
            [[self entity] name], [self name],
            [NSNumber numberWithInt:_deleteRule] /*[ODORelationshipDeleteRuleEnumNameTable() nameForEnum:_deleteRule]*/,
            [_inverseRelationship isToMany] ? @"<<" : @"<",
            [self isToMany] ? @">>" : @">",
            [NSNumber numberWithInt:[_inverseRelationship deleteRule]]/*[ODORelationshipDeleteRuleEnumNameTable() nameForEnum:[_inverseRelationship deleteRule]]*/,
            [[_inverseRelationship entity] name], [_inverseRelationship name]];
}

- (NSMutableDictionary *)debugDictionary;
{
    NSMutableDictionary *dict = [super debugDictionary];
    [dict setObject:ODOPropertyFlags(self).toMany ? @"true" : @"false" forKey:@"isToMany"];
    [dict setObject:[[self destinationEntity] name] forKey:@"destinationEntity"]; // call access to hit assertion that these are valid
    [dict setObject:[[self inverseRelationship] name] forKey:@"inverseRelationship"];
    return dict;
}
#endif

#pragma mark -
#pragma mark Creation

ODORelationship *ODORelationshipCreate(NSString *name, BOOL optional, BOOL transient, SEL get, SEL set,
                                       BOOL toMany, ODORelationshipDeleteRule deleteRule)
{
    OBPRECONDITION(deleteRule > ODORelationshipDeleteRuleInvalid);
    OBPRECONDITION(deleteRule < ODORelationshipDeleteRuleCount);
    
    ODORelationship *rel = [[ODORelationship alloc] init];
    
    struct _ODOPropertyFlags baseFlags;
    memset(&baseFlags, 0, sizeof(baseFlags));
    baseFlags.snapshotIndex = ODO_NON_SNAPSHOT_PROPERTY_INDEX; // start out not being in the snapshot properties; this'll get updated later if we are
    
    // Add relationship-specific info to the flags
    baseFlags.relationship = YES;
    baseFlags.toMany = toMany;
    
    ODOPropertyInit(rel, name, baseFlags, optional, transient, get, set);
    
    rel->_deleteRule = deleteRule;
    
    return rel;
}

void ODORelationshipBind(ODORelationship *self, ODOEntity *sourceEntity, ODOEntity *destinationEntity, ODORelationship *inverse)
{
    OBPRECONDITION([self isKindOfClass:[ODORelationship class]]);
    OBPRECONDITION(destinationEntity);
    OBPRECONDITION(inverse);
    
    ODOPropertyBind(self, sourceEntity);
    
    self->_destinationEntity = [destinationEntity retain];
    self->_inverseRelationship = [inverse retain];
}

@end
