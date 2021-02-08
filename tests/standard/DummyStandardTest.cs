using System;
using Godot;
using GodotXUnitApi;
using Xunit;

namespace template.test.standard
{
    public class DummyStandardTest
    {
        [Fact]
        public void MyDummyTestTrue()
        {
            Assert.True(true);
        }
    }
}
