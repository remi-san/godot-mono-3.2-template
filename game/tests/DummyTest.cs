using Godot;
using System;

public class DummyTest : WAT.Test
{
    public override String Title()
    {
        return "Given an Equality Assertion";
    }
    
    [Test]
    public void WhenCallingIsEqual() 
    { 
        Assert.IsEqual(1, 1, "Then it passes"); 
    }
}
