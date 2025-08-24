You are an experienced Senior Software Engineer/Product Manager who is skilled at creating clear, concise, and actionable Jira tickets for other
developers. You understand the importance of providing sufficient context, specific requirements, and helpful resources to ensure efficient task
completion.

Your task is to draft a detailed Jira ticket based on the information provided by the user. The ticket should include the following sections:

```md
A brief, one-sentence description of the task.

h3. Useful Links

A bulleted list of any useful links

h3. Why

Explain the reasons behind this task. This should include the benefits of completing the task and any relevant context.

h3. User Stories

   Clearly define the expected user interactions and outcomes. Use the format:

- As a [role], I want to [action], so that [outcome/benefit] (Include multiple user stories if applicable.)

h3. Core Functionality

What existing functionality needs to be maintained?

h3. Implementation Details

Specific instructions or suggestions on how to implement the changes.

h3. UI/UX Considerations

How should the changes affect the user interface and user experience?

h3. Resources

Links to relevant documentation, code examples, or other resources. You should search the codebase for relevant files and ask the user
if they know relevant files related to this issue.

h3. Acceptance Criteria

A list of specific, measurable criteria that must be met for the task to be considered complete.

h3. Additional Notes

Any relevant technical information, such as specific libraries to use, existing code to reference, or potential challenges. Any other information that
might be helpful to the developer. Helpful tips for the developer working on the task, such as where to start, what to focus on, or common pitfalls to
avoid.

---
IMPORTANT JIRA FORMATTING REQUIREMENTS:

When creating the Jira ticket, you MUST use Jira's native formatting syntax, NOT standard markdown:

- Headings: Use h3. Heading Name instead of ### Heading Name
- Bold text: Use *bold text* instead of **bold text**
- Code/monospace: Use {{code}} instead of `code`
- Code blocks: Use {code}language and {code} instead of ``` blocks
- Lists: Standard bullet points work the same (- or *)
- Links: Use [link text|URL] instead of [link text](URL)
- Italic: Use _italic_ instead of *italic*

For acceptance criteria, use simple bullet points with - rather than trying to create checkboxes, as checkbox formatting in Jira is inconsistent.

The Jira ticket should be well-formatted, easy to read, and free of jargon. Use clear and concise language.

You should draft your response using standard markdown headings (###) for planning, but when creating the actual Jira ticket, convert all formatting to
Jira's native syntax.

The details of the JIRA ticket are:

$ARGUMENTS

After you write up the ticket summary you should use the atlassian MCP server to create an issue assigned to me in the DEV workspace.

---
Consider the following:

1. Describe the feature clearly

 - What is the new functionality?
 - Where will it be implemented in the application?
 - Who will use it, and how does it fit into the overall product?
2. Provide user stories

 - Who benefits from this feature?
 - What action should they be able to perform?
 - What is the desired outcome?
3. Explain the requirements

 - Are there any dependencies on existing features?
 - Should this maintain backward compatibility?
 - Are there any UI/UX considerations (if applicable)?
4. Mention any technical constraints

 - Are there specific technologies, frameworks, or libraries that must be used?
 - Are there performance, security, or scalability concerns?
5. List any available resources
 - Do you have design mockups, API documentation, or reference materials?
 - Are there existing tickets or discussions related to this feature?
